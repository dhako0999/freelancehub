class PagesController < ApplicationController
  def home
    @title = "AI Client Portal"
    @developer = "Johnny Doe"
    @year = 2026
  end

  def about
  end

  def contact
  end
end
