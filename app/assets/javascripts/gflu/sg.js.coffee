# The Google Flu Trends streamgraph code.
# WIDTH = 700
MARGIN = 40
WIDTH = window.innerWidth - MARGIN
HEIGHT = window.innerHeight - MARGIN
sgData = null
weeks = null
regions = null
regionPaths = null
graphOffsetType = 'zero'
duration = 750
area = null
streamgraph = null
colors = null

@drawStreamGraph = () ->
  haveAllData = () -> (sgData and weeks and regions)

  jQuery.getJSON('/sg.json', (sgDataIn) ->
    sgData = sgDataIn
    draw() if haveAllData()
  )

  jQuery.getJSON('/week_dates.json', (weeksIn) ->
    weeks = weeksIn
    draw() if haveAllData()
  )

  jQuery.getJSON('/regions.json', (regionsIn) ->
    regions = regionsIn
    draw() if haveAllData()
  )

draw = () ->
  if (! tooltip)
    tooltip = MyToolTip('tooltip')
  iRegion = -1

  bodyMouseMove = () ->
    () ->
      setLinePosition(d3.mouse(this))

  sgElement = d3.select('div#gf_stream_graph')
  svg = sgElement.append('svg')
      .attr('width', WIDTH)
      .attr('height', HEIGHT)
      .on('mousemove', bodyMouseMove())

  #loop through weeks - for each week
  #    loop through all the regions adding up the values
  #totUS = for regionName in regions
  #get the total of every region in one date
  weeks.forEach((week,iWeek) ->
    #loop through the regions
    totForWeek = 0
    sgData.forEach((regionData) ->
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
    .tickSize(-HEIGHT)

  #send sgData into the stack/wiggle calculation - it creates
  #  the additional data needed for the layout of the graph
  #  this changes the contents of sgData
  d3.layout.stack()
    .offset(graphOffsetType)(sgData)

  #add the yScale
  # max y value
  maxHeight = d3.max(sgData, (layer) -> d3.max(layer, (pt) -> pt.y0 + pt.y))
  yScale = d3.scale.linear()
    .domain([0, maxHeight])
    .range([HEIGHT - MARGIN, 0])

  #define which color range we'll use
  colors = d3.scale.category20b()

  #draw the streamgraph visualization
  area = d3.svg.area()
    .interpolate('cardinal')
    .x((d) -> xScale(parseDate(weeks[d.x]['date'])))
    .y0((d) -> yScale(d.y0))
    .y1((d) -> yScale(d.y0 + d.y))

  #mouse tracker vertical line
  setLinePosition = (mousePosition) ->
    iDate = dateFromPos(mousePosition[0])
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
        tooltip.Show(d3.event, ttHtml )

  d3.select('svg')
    .append('line')
    .attr('id', 'xline')
    .attr('x1', 50)
    .attr('y1', 0)
    .attr('x2', 50)
    .attr('y2', HEIGHT - MARGIN)
    .style('stroke', 'darkgray')
    .style('stroke-width', 2)

  regionColor = null
  mouseover = () ->
    (g, i) ->
      iRegion = i
      regionColor = this.style.fill
      this.style.fill = 'black'
      this.style.stroke = 'black'
      setLinePosition(d3.mouse(this))
  mouseout = () ->
    (g, i) ->
      this.style.fill = regionColor
      this.style.stroke = regionColor
      iRegion = -1
      setLinePosition(d3.mouse(this))

  streamgraph = svg.selectAll('.region')
    .data(sgData)
    .enter()

  regionPaths = streamgraph
    .append('g')
    .attr('class', 'region')

  paths = regionPaths.append('path')
    .attr('class', 'area')
    .style('fill', () -> colors(Math.random()))
    .attr('d', area)
    .on('mouseover', mouseover())
    .on('mouseout', mouseout())

  d3.select('svg')
    .append('g')
    .attr('class', 'x axis')
    .attr('transform', 'translate(0,' + (HEIGHT - MARGIN) + ')')
    .call(xAxis)

  dateFromPos = (mouse) ->
    date = xScale.invert(mouse)
    format = d3.time.format('%Y-%m-%d')
    dateString = format(date)
    bisect = d3.bisector((d) -> d['date']).left
    iDate = bisect(weeks, dateString)
    if (iDate >= weeks.length)
      iDate = weeks.length - 1
    return iDate

  changeVisType = (offset, btnThis) ->
    graphOffsetType = offset
    btnText = btnThis.text()
    btnThis.text('   loading...')
    jQuery.getJSON('/sg.json', (sgDataIn) ->
      sgData = sgDataIn

      #change sgData to the graphOffsetType
      if graphOffsetType is 'line'
        sgData.forEach((region) ->
          region.forEach((week) ->
             week.y0 = 0
          )
        )
      else
        d3.layout.stack()
          .offset(graphOffsetType)(sgData)
      maxHeight = d3.max(sgData, (layer) -> d3.max(layer, (pt) -> pt.y0 + pt.y))
      yScale = d3.scale.linear()
        .domain([0, maxHeight])
        .range([HEIGHT - MARGIN, 0])

      svg.selectAll('.region')
        .data(sgData)
        .enter()
      a = svg.selectAll('.region')
        .select('.area')
      if graphOffsetType is 'line'
        a.style('stroke', () -> this.style.fill)
          .style('stroke-width', 2)
          .style('fill', 'none')
          .on('mouseover', (g,i) ->
            iRegion = i
            j = 0
            for regionPath in regionPaths[0]
              if j != iRegion
                regionPath.style.strokeOpacity = .2
              j += 1
            )
          .on('mouseout', (g,i) ->
            for regionPath in regionPaths[0]
              regionPath.style.strokeOpacity = 1
            iRegion = -1
          )
      else
        a.style('fill', () ->
            if this.style.fill is 'none'
              this.style.stroke
            else
              this.style.fill
          )
          .style('stroke', () -> this.style.fill)
          .on('mouseover', mouseover())
          .on('mouseout', mouseout())
      t = svg.selectAll('.region')
        .transition()
        .delay(0)
        .duration(3500)
      t.select('.area')
        .attr('d', (d)->area(d))
      btnThis.text(btnText)
    )

  streamButton = d3.select('#stream')
    .on('click', () ->
        streamButton.attr('disabled', true)
        stackButton.attr('disabled', null)
        lineButton.attr('disabled', null)
        changeVisType('wiggle', streamButton)
    )
  stackButton = d3.select('#stack')
    .attr('disabled', true)
    .on('click', () ->
        streamButton.attr('disabled', null)
        stackButton.attr('disabled', true)
        lineButton.attr('disabled', null)
        changeVisType('zero', stackButton))
  lineButton = d3.select('#linechart')
    .on('click', () ->
      streamButton.attr('disabled', null)
      stackButton.attr('disabled', null)
      lineButton.attr('disabled', true)
      changeVisType('line', lineButton))
