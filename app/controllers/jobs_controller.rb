class JobsController < ApplicationController

	def index
		require 'will_paginate/array'

		session[:return_to] = nil

		@jobs = Job.search(params[:search], params[:location]).paginate(:page => params[:page])	
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
	