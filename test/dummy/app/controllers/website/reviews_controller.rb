# frozen_string_literal: true

module Website
  class ReviewsController < BaseController
    def index
      render json: ReviewStore.for_path(params[:path].to_s)
    end

    def create
      review = ReviewStore.add(review_params)
      if review
        render json: review, status: :created
      else
        render json: { error: 'Could not save that comment.' }, status: :unprocessable_entity
      end
    end

    def update
      review = ReviewStore.move(params[:id], params[:x], params[:y])
      review ? render(json: review) : head(:not_found)
    end

    def reply
      review = ReviewStore.reply(params[:id], reply_params)
      if review
        render json: review
      else
        render json: { error: 'Could not save that reply.' }, status: :unprocessable_entity
      end
    end

    def destroy
      removed = ReviewStore.remove(params[:id], params[:author])
      removed ? head(:no_content) : head(:forbidden)
    end

    def destroy_reply
      review = ReviewStore.remove_reply(params[:id], params[:reply_id], params[:author])
      review ? render(json: review) : head(:forbidden)
    end

    def image
      path = ReviewStore.image_path(params[:id])
      return head :not_found unless path

      send_file path, type: 'image/jpeg', disposition: 'inline'
    end

    private

    def review_params
      params.require(:review).permit(:path, :kind, :quote, :prefix, :body, :author, :image, :x, :y,
                                     region: %i[x y w h stroke])
    end

    def reply_params
      params.require(:reply).permit(:body, :author)
    end
  end
end
