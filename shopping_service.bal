import ballerina/grpc;


// Define the gRPC Service with Descriptor
@grpc:ServiceDescriptor {
    descriptor: SHOPPING_DESC
}
service "ShoppingService" on new grpc:Listener(9090) {

    private table< Product> key(sku) products = table [];
    private table<readonly & User> key(id) users = table [];
    private map<CartItem[]> carts = {};

    // Admin: Add a product
    remote function AddProduct(Product product) returns ProductResponse|error {
        // Add the product directly without casting
         self.products.add(product);
        return {product_code: product.sku}; // Return the product code (SKU)
    }

    // Admin: Update a product
    remote function UpdateProduct(Product product) returns ProductResponse|error {
        if (!self.products.hasKey(product.sku)) {
            return error("Product not found");
        }
        _ = self.products.put(product); // No need for casting
        return {product_code: product.sku}; // Return updated product code
    }

    // Admin: Remove a product
    remote function RemoveProduct(ProductCode productCode) returns ProductList|error {
        if (!self.products.hasKey(productCode.code)) {
            return error("Product not found");
        }
        _ = self.products.remove(productCode.code);
        return {products: self.products.toArray()}; // Return updated list of products
    }

    // Customer: List available products
    remote function ListAvailableProducts(Empty value) returns ProductList|error {
        Product[] availableProducts = from var product in self.products
                                      where product.status == "available"
                                      select product;
        return {products: availableProducts}; // Return available products only
    }

    // Customer: Search for a specific product by SKU
    remote function SearchProduct(ProductCode productCode) returns Product|error {
        Product? product = self.products[productCode.code];
        if (product is ()) {
            return error("Product not found");
        }
        return product; // Return the found product
    }

    // Customer: Add item to the cart
    remote function AddToCart(CartItem cartItem) returns CartResponse|error {
        if (!self.users.hasKey(cartItem.userId)) {
            return error("User not found");
        }
        if (!self.products.hasKey(cartItem.sku)) {
            return error("Product not found");
        }
        CartItem[]? userCart = self.carts[cartItem.userId];
        if (userCart is ()) {
            self.carts[cartItem.userId] = [cartItem]; // Initialize a new cart
        } else {
            userCart.push(cartItem); // Add item to the existing cart
        }
        return {message: "Product added to cart"}; // Confirm item added to cart
    }

    // Customer: Place an order based on the user's cart
       // Customer: Place an order based on the user's cart
    remote function PlaceOrder(UserId userId) returns OrderResponse|error {
    CartItem[]? userCart = self.carts[userId.id]; // Access the 'id' field
    if (userCart is ()) {
        return error("Cart is empty");
    }
    
    // Example: Order ID generation
    string orderId = "ORDER-" + userId.id;

    // Remove items from cart after placing the order
    _ = self.carts.remove(userId.id); 
    
    // Return order confirmation with the correct field names
    return {success: true, orderId: orderId, message: "Order placed successfully"};
}


}
