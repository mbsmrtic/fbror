class HdrQuotesController < ApplicationController

  #GET /hdr_quotes
  #GET /hdr_quotes.json
  def index
    @hdr_quotes = HdrQuote.all

    respond_to do |format|
      format.html #index.html.erb
      format.json { render json: @hdr_quotes }
    end
  end

  #GET /hdr_quotes/1
  #GET /hdr_quotes/1.json
  def show
    @hdr_quote = HdrQuote.find(params[:id])
    respond_to do |format|
      format.html #show.html.erb
      format.json { render json: @hdr_quote}
    end
  end

  #GET /hdr_quotes/new
  #GET /hdr_quotes/new.json
  def new
    @hdr_quote = HdrQuote.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @hdr_quote }
    end
  end

  # POST /hdr_quotes
  # POST /hdr_quotes.json
  def create
    @hdr_quote = HdrQuote.new(params[:hdr_quote])

    respond_to do |format|
      if @hdr_quote.save
        format.html { redirect_to hdr_quotes_path, notice: 'Quote was successfully created.' }
        format.json { render json: @hdr_quote, status: :created, location: @hdr_quote }
      else
        format.html { render action: 'new' }
        format.json { render json: @hdr_quote.errors, status: :unprocessable_entity }
      end
    end

  end

  def destroy
    @hdr_quote = HdrQuote.find_by_id(params[:id])
    @hdr_quote.destroy
    redirect_to(hdr_quotes_path)
  end
end
