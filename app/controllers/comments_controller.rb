class CommentsController < ApplicationController

  def index
    @comments = Job.find(params[:id]).comments
  end
end
