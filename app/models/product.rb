class Product < ActiveRecord::Base
	# this has many line_items
	has_many :line_items
	before_destroy :ensure_not_referenced_by_any_line_item

	validates :title, :description, :image_url, presence: true 
	validates :description, length: { minimum: 10 }
	validates :price, numericality: { greater_than_or_equal_to: 0.01 }
	validates :title, uniqueness: true 
	validates :image_url, allow_blank: true, format: {
		with: %r{\.(gif|jpg|png)\Z}i,
		message: 'must be a URL for GIF, JPG or PNG image.'
	}

	private
	def ensure_not_referenced_by_any_line_item
		if line_items.empty?
			return true
		else
			errors.add(:base, 'Line Items Present')
			return false
		end
	end

	# this will put the products in order
	def self.latest
		Product.order(:updated_at).last
	end
end
