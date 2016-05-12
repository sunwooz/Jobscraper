class JobsController < ApplicationController
	before_filter :authenticate_user!, :only => [:destroy]

	def index
		require 'will_paginate/array'

		session[:return_to] = nil

		@cities = City.all.order("name ASC")

		if params.keys.include?('city')
			@jobs = Job.search(params[:search], params[:city][:location]).paginate(:page => params[:page], :per_page => 6)
		else
			@jobs = []
		end
	end

	def destroy
		session[:return_to] ||= request.referer
		@job = Job.find(params[:id]).delete
		redirect_to session[:return_to]
	end

	def edit
		@job = Job.find(params[:id])
		respond_to do |format|
			format.html
		end
	end

	def update
		job = Job.find(params[:id])
		if job.update(company: params[:job][:company])
			redirect_to(:back)
		end
	end

	def destroy
		job = Job.find(params[:id])
		
		respond_to do |format|
			if job.destroy
				format.js { render layout: false, action: 'destroy_success' }
			else
				format.js { render layout: false, action: 'destroy_failure' }
			end
		end
	end
end
