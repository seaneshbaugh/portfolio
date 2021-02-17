# frozen_string_literal: true

class LinksController < ApplicationController
  MINIMUM_YEAR = 2021
  MAXIMUM_YEAR = 2121

  def index
    @year = params[:year]
    @month = params[:month]

    @links = find_links

    if @year
      if @month
        render 'index_month'
      else
        render 'index_year'
      end
    else
      render 'index_all'
    end
  end

  private

  def find_links
    links = if @year.present?
              raise ActionController::RoutingError, 'Not Found' if selected_date.year < MINIMUM_YEAR || selected_date.year > MAXIMUM_YEAR

              Link.published.chronological.where(published_at: start_date..end_date)
            else
              Link.published.chronological
            end

    if params[:tag].present?
      links.tagged_with(params[:tag])
    else
      links
    end
  rescue ArgumentError, TypeError
    raise ActionController::RoutingError, 'Not Found'
  end

  def end_date
    return if @year.blank?

    @end_date ||= if @month.present?
                    selected_date.end_of_month
                  else
                    selected_date.end_of_year
                  end
  end

  def start_date
    return if @year.blank?

    @start_date ||= if @month.present?
                      selected_date.beginning_of_month
                    else
                      selected_date.beginning_of_year
                    end
  end

  def selected_date
    return if @year.blank?

    @selected_date ||= if @month.present?
                         Time.zone.parse("#{@year}-#{@month}-01")
                       else
                         Time.zone.parse("#{@year}-01-01")
                       end
  end
end
