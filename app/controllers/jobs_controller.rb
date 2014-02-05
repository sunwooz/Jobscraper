class JobsController < ApplicationController

	def index
		if params[:search].blank?
			@search = nil
			@jobs = []
		else
			@search = Job.search do
				fulltext params[:search]
			end
			@jobs = @search.results
		end
	end

	def show
		@job = Job.find(params[:id])
	end

	def destroy
		session[:return_to] ||= request.referer
		@job = Job.find(params[:id]).delete
		redirect_to session[:return_to]
	end
end
