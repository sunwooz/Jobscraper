class JobsController < ApplicationController
	before_filter :authenticate_user!, :only => [:destroy]

	def index
		require 'will_paginate/array'

		session[:return_to] = nil

		@cities = City.all.order("name DESC")

		if params.keys.include?('city')
			@jobs = Job.search(params[:search], params[:city][:location]).paginate(:page => params[:page])
		else
			@jobs = []
		end
	end

	def destroy
		session[:return_to] ||= request.referer
		@job = Job.find(params[:id]).delete
		redirect_to session[:return_to]
	end
end
