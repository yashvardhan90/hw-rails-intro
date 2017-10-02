class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @sort = params[:sort]
    @all_ratings = Movie.distinct.pluck(:rating)
    @movies = Movie.all

    unless params[:ratings].nil?
      @select_ratings = params[:ratings]
      session[:select_ratings] = @select_ratings
    end

    if params[:sorting_var].nil?
      #
    else
      session[:sorting_var] = params[:sorting_var]
    end

    if params[:sorting_var].nil? && params[:ratings].nil? && session[:select_ratings]
      @select_ratings = session[:select_ratings]
      @sorting_var = session[:sorting_var]
      flash.keep
      redirect_to movies_path({order_by: @sorting_var, ratings: @select_ratings})
    end

    if session[:select_ratings]
      @movies = @movies.select{ |movie| session[:select_ratings].include? movie.rating }
    end

    if session[:sorting_var] == "title"
      @movies = @movies.sort { |a,b| a.title <=> b.title }
      @movie_column_class = "hilite"
    elsif session[:sorting_var] == "release_date"
      @movies = @movies.sort { |a,b| a.release_date <=> b.release_date }
      @date_column_class = "hilite"
    else
    
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
