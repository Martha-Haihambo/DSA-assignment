import ballerina/io;

// Create a gRPC client to communicate with the server
 client:ShoppingServiceClient shoppingClient = check new ("http://localhost:9090");

public function shopping_client() {
    io:println("Client started successfully. Choose an operation:");
    io:println("Choose an operation:");
    io:println("1. Add Product");
    io:println("2. List Available Products");
    io:println("3. Search Product by SKU");
    io:println("4. Add to Cart");
    io:println("5. Place Order");

    string? choice = io:readln("Enter your choice (1-5): ");
    
    match choice {
        "1" => addProduct();
        "2" => listAvailableProducts();
        "3" => searchProduct();
        "4" => addToCart();
        "5" => placeOrder();
        _   => io:println("Invalid choice");
    }
}

function addProduct() {
    // Read product details from user input
    string sku = check io:readln("Enter product SKU: ");
    string name = check io:readln("Enter product name: ");
    string description = check io:readln("Enter product description: ");
    string priceInput = check io:readln("Enter product price: ");
    float price = check 'float:fromString(priceInput);
    string status = check io:readln("Enter product status (available/unavailable): ");

    // Create the product message
    client:Product product = {
        sku: sku,
        name: name,
        description: description,
        price: price,
        status: status
    };

    // Call the AddProduct function on the server
    var response = shoppingClient->AddProduct(product);
    if (response is client:ProductCode) {
        io:println("Product added successfully! Product Code: " + response.code);
    } else {
        io:println("Failed to add product: " + response.toString());
    }
}

function listAvailableProducts() {
    // Call the ListAvailableProducts function on the server
    var response = shoppingClient->ListAvailableProducts({});
    if (response is client:ProductList) {
        io:println("Available products:");
        foreach var product in response.products {
            io:println("SKU: " + product.sku + ", Name: " + product.name + ", Price: " + product.price.toString());
        }
    } else {
        io:println("Failed to list products: " + response.toString());
    }
}

function searchProduct() {
    // Read the SKU from user input
    string sku = check io:readln("Enter product SKU to search: ");

    // Create the ProductCode message
    client:ProductCode productCode = {code: sku};

    // Call the SearchProduct function on the server
    var response = shoppingClient->SearchProduct(productCode);
    if (response is client:Product) {
        io:println("Product found: " + response.name + " (Price: " + response.price.toString() + ")");
    } else {
        io:println("Product not found: " + response.toString());
    }
}

function addToCart() {
    // Read user ID and product SKU from input
    string userId = check io:readln("Enter user ID: ");
    string sku = check io:readln("Enter product SKU to add to cart: ");

    // Create the CartItem message
    client:CartItem cartItem = {
        userId: userId,
        sku: sku
    };

    // Call the AddToCart function on the server
    var response = shoppingClient->AddToCart(cartItem);
    if (response is client:CartResponse) {
        io:println(response.message);
    } else {
        io:println("Failed to add item to cart: " + response.toString());
    }
}

function placeOrder() {
    // Read the user ID
    string userId = check io:readln("Enter user ID to place the order: ");

    // Create the UserId message
    client:UserId userIdMessage = {id: userId};

    // Call the PlaceOrder function on the server
    var response = shoppingClient->PlaceOrder(userIdMessage);
    if (response is client:OrderResponse) {
        io:println("Order placed! Order ID: " + response.orderId);
    } else {
        io:println("Failed to place order: " + response.toString());
    }
}
