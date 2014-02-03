class JobsController < ApplicationController

	def index
		@search = Job.search do
			fulltext params[:search]
		end
		@jobs = @search.results
	end

	def show
		@job = Job.find(params[:id])
	end

	def destroy
		@job = Job.find(params[:id]).delete
		redirect_to jobs_path
	end
end
