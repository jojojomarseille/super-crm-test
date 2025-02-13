class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :update_price]
  before_action :set_price, only: [:update_price]

  # 📋 Listar todos os produtos
  def index
    order = params[:order] || 'name'  # Se não passar um parâmetro `order`, usa 'name' como padrão
    direction = params[:direction] || 'asc'  # Se não passar um parâmetro `direction`, usa 'asc' como padrão

    # Verifica se a direção é 'desc' para reverter a ordem
    if %w[name price stock].include?(order) && %w[asc desc].include?(direction)
      @products = Product.order("#{order} #{direction}")
    else
      @products = Product.all # Caso não haja parâmetros válidos
    end
  end

  # 👁️ Mostrar detalhes de um produto
  def show
  end

  # ➕ Formulário para novo produto
  def new
    @product = Product.new
    @product.prices.build
  end

  # 📝 Formulário para editar produto
  def edit
  end

  # Atualizar preço diretamente da página de produto
  def update_price
    if @price.update(price_params)
      redirect_to @product, notice: 'Preço atualizado com sucesso.'
    else
      redirect_to @product, alert: 'Erro ao atualizar preço.'
    end
  end

  # 💾 Salvar novo produto
  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to @product, notice: 'Produto criado com sucesso.'
    else
      render :new
    end
  end

  # 🔄 Atualizar produto existente
  def update
    if @product.update(product_params)
      redirect_to @product, notice: 'Produto atualizado com sucesso.'
    else
      render :edit
    end
  end

  # 🗑️ Deletar produto
  def destroy
    @product.destroy
    redirect_to products_url, notice: 'Produto excluído com sucesso.'
  end

  private

  # 🔑 Buscar produto por ID
  def set_product
    @product = Product.find(params[:id])
  end

  # 📦 Parâmetros permitidos para o produto
  def product_params
    params.require(:product).permit(:name, :description, :price, :stock, :product_image, prices_attributes: [:id, :amount, :currency, :_destroy])
  end

  # Parâmetros permitidos para o preço
  def price_params
    params.require(:price).permit(:amount, :currency)
  end

  # 🔑 Buscar o preço específico de um produto
  def set_price
    @price = @product.prices.find(params[:price_id])
  end
end
