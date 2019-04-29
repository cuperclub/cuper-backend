module Api
  module Admin
    class CategoriesController < BaseController
      before_action :find_category,
                    except: [:index, :create]

      api :GET,
          "/admin/categories",
          "Get all categories"
    example %q{
      "category":[{
        "name":"Food",
        "points_per_dollar":"2"
      }]
    }

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
          "/admin/categories",
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

      api :GET,
          "/admin/categories/:id",
          "Get a category"
      param :id, Integer, required: true
      example %q{
        "category":{
          "name":"Food",
          "points_per_dollar":"2"
        }
      }

      def show
        render :category,
                status: :accepted,
                locals: { category: @category }
      end

      api :PUT,
          "/admin/categories/:id",
          "Edit a category"
      param :id, Integer, required: true
      example %q{
        "category":{
          "name":"Food",
          "points_per_dollar":"2"
        }
      }

      def update
        if @category.update(category_params)
          render :category,
                  status: :accepted,
                  locals: { category: @category }
        else
          render json: @category.errors,
                status: :unprocessable_entity
        end
      end

      private

      def find_category
        @category = Category.find(params[:id])
      end

      def category_params
        params.require(:category).permit(
          :name,
          :points_per_dollar,
          :active
        )
      end
    end
  end
end
