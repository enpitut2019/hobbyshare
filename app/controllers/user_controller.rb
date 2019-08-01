class UserController < ApplicationController
  def select
    @users = User.all
  end

  def show
    @id = params[:select_user_id]
    @selected_data = User.find(@id)
    @queries = []
    @queries.push(@selected_data.hobby1).push(@selected_data.hobby2).push(@selected_data.hobby3)
    @search_results = []
    @queries.each do |q|
      @search_results.push(User.where(hobby1: q))
      @search_results.push(User.where(hobby2: q))
      @search_results.push(User.where(hobby3: q))
    end
    @search_results.uniq!
  end
end
