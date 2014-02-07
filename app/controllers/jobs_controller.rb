class JobsController < ApplicationController

	def index
		require 'will_paginate/array'

		session[:return_to] = nil

		@search = nil; @jobs = [] if params[:search].blank?
		if !params[:search].blank?
			@search = Job.search do
				fulltext params[:search]
				paginate :page => params[:page] || 1, :per_page => 15
				order_by(:created_at, :desc)
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
	