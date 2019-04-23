module Api
  class CategoriesController < BaseController

    def index
      categories = Category.all
      render :categories,
            status: :created,
            locals: { categories: categories }
    end

    def_param_group :category do
      param :name, String,
            required: true
      param :points_per_dollar, Integer,
            required: true
    end

    api :POST,
        "/categories",
        "Submit a category application. Response includes the errors if any."
    param_group :category
    example %q{
      "category":{
        "name":"Food",
        "points_per_dollar":"2"
      }
    }

    def create
      category = Category.new(category_params)

      if category.save
        render :category,
              status: :created,
              locals: { category: category }
      else
        render json: category.errors,
              status: :unprocessable_entity
      end
    end

    def show
      category = Category.find(params[:id])
      if category
        render :category,
                status: :accepted,
                locals: { category: category }
      else
        render json: nil,
              status: :not_found
      end
    end

    private

    def category_params
      params.require(:category).permit(
        :name,
        :points_per_dollar
      )
    end
  end
end
