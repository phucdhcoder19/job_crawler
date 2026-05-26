module Admin
  class JobsController < ApplicationController
    PER_PAGE = 25

    before_action :set_job, only: [ :edit, :update, :destroy ]
    def index
      @jobs = Job
              .search_title(params[:q])
              .by_location(params[:location])
              .recent
              .page(params[:page])
              .per(PER_PAGE)

      @locations = Job.distinct_locations
    end

    def edit
    end

    def update
      if @job.update(job_params)
        flash[:notice] = "Đã cập nhật việc làm."
        redirect_to admin_jobs_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @job.destroy
      flash[:notice] = "Đã xóa việc làm."
      redirect_to admin_jobs_path
    end

    private

    def set_job
      @job = Job.find(params[:id])
    end

    def job_params
      params.require(:job).permit(
        :title, :company_name, :salary, :location,
        :job_url, :posted_at, :description
      )
    end
  end
end
