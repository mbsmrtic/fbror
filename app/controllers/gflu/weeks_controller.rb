class Gflu::WeeksController < ApplicationController
  def index
    @weeks = Week.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @weeks }
    end
  end
end
