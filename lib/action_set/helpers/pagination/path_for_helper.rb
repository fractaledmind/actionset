module Pagination
  module PathForHelper
    def paginate_path_for(page)
      page ||= 1
      url_for paginate_params_for(page)
    end

    private

    def paginate_params_for(page)
      current_params.merge(paginate: {
        page: page
      })
    end
  end
end
