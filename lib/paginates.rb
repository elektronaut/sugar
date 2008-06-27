module Paginates
    attr_reader :pages, :current_page, :total_count, :offset
    def setup_pagination(pages, current_page, total_count, offset)
        @pages, @current_page, @total_count, @offset = pages, current_page, total_count, offset
    end
    def previous_page
        (@current_page > 1) ? (@current_page - 1) : nil
    end
    def next_page
        (@pages > @current_page) ? (@current_page + 1) : nil
    end
end