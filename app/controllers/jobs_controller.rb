class JobsController < ApplicationController
  PER_PAGE = 20


  def index
    @jobs = Job
            .search_title(params[:q])
            .by_location(params[:location])
            .recent
            .page(params[:page])
            .per(PER_PAGE)

    @locations = Job.distinct_locations
  end

  def show
    @job = Job.find(params[:id])
  end
end
