class ScrollTestsController < ApplicationController
  before_action :set_scroll_test, only: [:show, :edit, :update, :destroy]

  # GET /scroll_tests
  # GET /scroll_tests.json
  def index
    #@scroll_tests = ScrollTest.all
    @scroll_tests = ScrollTest.order(:created_at).page(params[:page])
  end

  # GET /scroll_tests/1
  # GET /scroll_tests/1.json
  def show
  end

  # GET /scroll_tests/new
  def new
    @scroll_test = ScrollTest.new
  end

  # GET /scroll_tests/1/edit
  def edit
  end

  # POST /scroll_tests
  # POST /scroll_tests.json
  def create
    @scroll_test = ScrollTest.new(scroll_test_params)

    respond_to do |format|
      if @scroll_test.save
        format.html { redirect_to @scroll_test, notice: 'Scroll test was successfully created.' }
        format.json { render action: 'show', status: :created, location: @scroll_test }
      else
        format.html { render action: 'new' }
        format.json { render json: @scroll_test.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scroll_tests/1
  # PATCH/PUT /scroll_tests/1.json
  def update
    respond_to do |format|
      if @scroll_test.update(scroll_test_params)
        format.html { redirect_to @scroll_test, notice: 'Scroll test was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @scroll_test.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scroll_tests/1
  # DELETE /scroll_tests/1.json
  def destroy
    @scroll_test.destroy
    respond_to do |format|
      format.html { redirect_to scroll_tests_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scroll_test
      @scroll_test = ScrollTest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scroll_test_params
      params.require(:scroll_test).permit(:title, :author, :body)
    end
end
