// @ts-ignore
import { createModule } from "@ui_eval/sdk";

// ========================================
// STATE & ACTION ENUMS (must match Dart)
// ========================================
enum State {
  products = "products",
  cart = "cart",
  selectedCategory = "selectedCategory",
  isLoading = "isLoading",
  totalPrice = "totalPrice",
}

enum Action {
  fetchProducts = "fetchProducts",
  addToCart = "addToCart",
  removeFromCart = "removeFromCart",
  clearCart = "clearCart",
  filterByCategory = "filterByCategory",
}

// ========================================
// TYPES
// ========================================
export interface Product {
  id: number;
  title: string;
  price: number;
  description: string;
  category: string;
  image: string;
  rating?: {
    rate: number;
    count: number;
  };
}

export interface CartItem extends Product {
  quantity: number;
}

// ========================================
// MODULE SETUP
// ========================================
const { defineAction, states, api, log, moduleId } =
  createModule("store_app");

log("Module initialized");

// ========================================
// HELPER FUNCTIONS
// ========================================
async function updateTotalPrice(): Promise<void> {
  const cart = await states.get<CartItem[]>(State.cart);
  const total = cart.reduce((sum, item) => sum + item.price * item.quantity, 0);
  await states.set(State.totalPrice, Math.round(total * 100) / 100);
}

// ========================================
// ACTIONS
// ========================================
export const fetchProducts = defineAction(Action.fetchProducts, async () => {
  try {
    await states.set(State.isLoading, true);
    log("🌐 Fetching products from API...");

    const response = await api.request({
      url: "https://fakestoreapi.com/products",
      method: "GET",
      useFlutterProxy: true,
    });

    log("📦 API Response received:", response);

    const products: Product[] = Array.isArray(response)
      ? response
      : response.products || [];

    // Limit to first 10 products for better UX
    const limitedProducts = products.slice(0, 10);

    await states.set(State.products, limitedProducts);
    await states.set(State.isLoading, false);

    log("✅ Fetched", limitedProducts.length, "products from API");
  } catch (error) {
    log("❌ Failed to fetch products:", error);
    await states.set(State.isLoading, false);
  }
});

export const addToCart = defineAction(
  Action.addToCart,
  async (_ctx: any, params: { index: number }) => {
    const index = params?.index as number;

    if (typeof index !== "number") {
      log("❌ Invalid product index");
      return;
    }

    const products = await states.get<Product[]>(State.products);

    if (index < 0 || index >= products.length) {
      log("❌ Product index out of bounds:", index);
      return;
    }

    const product = products[index];
    const cart = await states.get<CartItem[]>(State.cart);

    // Check if product already in cart
    const existingIndex = cart.findIndex((item) => item.id === product.id);

    if (existingIndex >= 0) {
      // Increment quantity
      const updatedCart = [...cart];
      updatedCart[existingIndex] = {
        ...updatedCart[existingIndex],
        quantity: updatedCart[existingIndex].quantity + 1,
      };
      await states.set(State.cart, updatedCart);
      log("➕ Increased quantity:", product.title);
    } else {
      // Add new item to cart
      const newCartItem: CartItem = { ...product, quantity: 1 };
      await states.set(State.cart, [...cart, newCartItem]);
      log("🛒 Added to cart:", product.title);
    }

    await updateTotalPrice();
  },
);

export const removeFromCart = defineAction(
  Action.removeFromCart,
  async (_ctx: any, params: { index: number }) => {
    const index = params?.index as number;

    if (typeof index !== "number") {
      log("❌ Invalid cart index");
      return;
    }

    const cart = await states.get<CartItem[]>(State.cart);

    if (index < 0 || index >= cart.length) {
      log("❌ Cart index out of bounds:", index);
      return;
    }

    const removedItem = cart[index];
    const updatedCart = cart.filter((_item, i) => i !== index);

    await states.set(State.cart, updatedCart);
    await updateTotalPrice();

    log("🗑️ Removed from cart:", removedItem.title);
  },
);

export const clearCart = defineAction(Action.clearCart, async () => {
  await states.set(State.cart, []);
  await states.set(State.totalPrice, 0);
  log("🧹 Cart cleared");
});

export const filterByCategory = defineAction(
  Action.filterByCategory,
  async (_ctx: any, params: { category: string }) => {
    const category = params?.category as string;
    await states.set(State.selectedCategory, category);
    log("🔍 Filter set to:", category);
  },
);

export { moduleId };
console.log(`[${moduleId}] Logic loaded successfully`);
