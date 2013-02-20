class Gflu::SgController < ApplicationController
  def index
    @regions = Region.all
    @weeks = Week.all
    sg_data = @regions.map {|region|
      name = region['name']
      i = -1
      @weeks.map { |week| {'x' => i += 1, 'y'=> week[name]}}
    }
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => sg_data }
    end
  end
end
