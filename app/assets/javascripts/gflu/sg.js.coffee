# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
WIDTH = 700
HEIGHT = 300
MARGIN = 20
sgData = null
weeks = null
regions = null

@drawStreamGraph = () ->
  graphDiv = d3.select('div#gf_stream_graph')

  haveAllData = () -> (sgData and weeks and regions)

  jQuery.getJSON('/sg.json', (sgDataIn) ->
    sgData = sgDataIn
    graphDiv = d3.select('div#gf_stream_graph')
    console.log('in coffee, got sgData')
    draw() if haveAllData()
  )

  jQuery.getJSON('/week_dates.json', (weeksIn) ->
    weeks = weeksIn
    console.log('in coffee, got week_dates')
    draw() if haveAllData()
  )

  jQuery.getJSON('/regions.json', (regionsIn) ->
    regions = regionsIn
    console.log('in coffee, got regions')
    draw() if haveAllData()
  )

draw = () ->
  console.log('in coffee in draw')
  if (! tooltip)
    tooltip = MyToolTip('tooltip')
  iRegion = -1

  #loop through weeks - for each week
  #    loop through all the regions adding up the values
  #totUS = for regionName in regions
  #get the total of every region in one date
  weeks.forEach((week,iWeek) ->
    #loop through the regions
    totForWeek = 0
    sgData.forEach((regionData, iRegion) ->
      totForWeek += regionData[iWeek].y
    )
    week.US = totForWeek
  )

  parseDate = d3.time.format("%Y-%m-%d").parse

  #add the x axis - the dates
  xScale = d3.time.scale()
    .range([MARGIN, WIDTH - MARGIN])
    .domain(d3.extent( weeks, (w) -> parseDate(w['date'])))

  xAxis =  d3.svg.axis()
    .scale(xScale)
    .orient('bottom')


  #send sgData into the stack/wiggle calculation - it creates
  #  the additional data needed for the layout of the graph
  #  this changes the contents of sgData
  d3.layout.stack().offset('wiggle')(sgData)

  #add the yScale
  # max y value
  maxHeight = d3.max(sgData, (layer) -> d3.max(layer, (pt) -> pt.y0 + pt.y))
  yScale = d3.scale.linear()
    .domain([0, maxHeight])
    .range([HEIGHT - MARGIN, 0])

  #define which color range we'll use
  color = d3.scale.category20b()

  #draw the streamgraph visualization
  area = d3.svg.area()
    .interpolate('cardinal')
    .x((d) ->
      date = parseDate(weeks[d.x]['date'])
      retval = xScale(date)
      return retval
    )
    .y0((d) -> yScale(d.y0))
    .y1((d) -> yScale(d.y0 + d.y))

  bodyMouseMove = () ->
    bmmfn = (g, i) ->
      setLinePosition(d3.mouse(this), d3.touches(this))

  bodyTouchEnd = () ->
    btmfn = (g, i) ->
      setLinePosition(d3.mouse(this), d3.touches(this))

  setLinePosition = (mousePosition, touches) ->
    iDate = dateFromPos(mousePosition)
    line = document.getElementById('xline')
    if (iDate == -1)
      line.style.display='none'
    else
      line.style.display = 'block'
      dateString = weeks[iDate]['date']
      date= parseDate(weeks[iDate]['date'])
      onScale = xScale(date)
      #add tooltip
      line.setAttribute('x1', onScale)
      line.setAttribute('x2', onScale)
      if (tooltip)
        ttHtml = "#{ dateString } <br><table><tr><td>United States:</td><td> #{weeks[iDate]['US']}</td></tr>"
        if (iRegion >= 0)
          ttHtml = ttHtml + "<tr><td>#{regions[iRegion].name}:</td>   <td>#{sgData[iRegion][iDate].y}</td></tr>"
        ttHtml = ttHtml + "</table>"
        ttHtml = ttHtml + touches.length
        tooltip.Show(d3.event, ttHtml )

  regionColor = null

  mouseover = () ->
    (g, i) ->
      iRegion = i
      regionPath = streamgraph[0][i]
      regionColor = regionPath.style.fill
      regionPath.style.fill = 'black'
      setLinePosition(d3.mouse(this))

  mouseout = () ->
    (g, i) ->
      regionPath = streamgraph[0][i]
      regionPath.style.fill = regionColor
      iRegion = -1
      setLinePosition(d3.mouse(this))

  #svg = d3.select('body').append('svg')
  svg = d3.select('div#gf_stream_graph').append('svg')
    .attr('width', WIDTH)
    .attr('height', HEIGHT)
    .on('touchend', bodyTouchEnd())
    .on('mousemove', bodyMouseMove())

  d3.select('svg')
    .append('line')
    .attr('id', 'xline')
    .attr('x1', 50)
    .attr('y1', 0)
    .attr('x2', 50)
    .attr('y2', HEIGHT - MARGIN)
    .style('stroke', 'darkgray')
    .style('stroke-width', 2)

  streamgraph = svg.selectAll('path')
    .data(sgData)
    .enter().append('path')
    .attr('d', area)
    .style('fill', () -> color(Math.random()))
    .on('mouseover', mouseover())
    .on('mouseout', mouseout())

  d3.select('svg')
    .append('g')
    .attr('class', 'x axis')
    .attr('transform', 'translate(0,' + (HEIGHT - MARGIN) + ')')
    .call(xAxis)


  dateFromPos = (mouse) ->
    date = xScale.invert(mouse[0])
    format = d3.time.format('%Y-%m-%d')
    dateString = format(date)
    bisect = d3.bisector((d) -> d['date']).left
    iDate = bisect(weeks, dateString)
    #iDate = weeks.indexOf(dateString)
    #if (iDate == -1)
    #  iDate = d3.bisectLeft(weeks, dateString)
    if (iDate >= weeks.length)
      iDate = weeks.length - 1
    date = parseDate(weeks[iDate]['date'])
    onscale = xScale(date)
    return iDate

