// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:ui_eval/dsl_only.dart';

/// ========================================
/// STATE & ACTION ENUMS
/// ========================================
enum State {
  products,
  cart,
  selectedCategory,
  isLoading,
  totalPrice,
}

enum Action {
  fetchProducts,
  addToCart,
  removeFromCart,
  clearCart,
  filterByCategory,
}

/// ========================================
/// E-commerce Store Mini App
/// ========================================
class StoreMiniApp {
  const StoreMiniApp();

  /// The UI program definition using type-safe DSL
  UIProgram get program => UIProgram(
        id: 'store_app',
        name: 'Store App',
        version: '1.0.0',
        states: [
          UIState.fromEnum(State.products,
              defaultValue: [], stateType: StateType.list),
          UIState.fromEnum(State.cart,
              defaultValue: [], stateType: StateType.list),
          UIState.fromEnum(State.selectedCategory,
              defaultValue: 'all', stateType: StateType.string),
          UIState.fromEnum(State.isLoading,
              defaultValue: false, stateType: StateType.bool),
          UIState.fromEnum(State.totalPrice,
              defaultValue: 0, stateType: StateType.double),
        ],
        root: UIScaffold(
          appBar: UIAppBar(
            title: 'Shopping Store',
            backgroundColor: 'purple',
            foregroundColor: 'white',
            actions: [
              UIIconButton(
                icon: 'shopping_cart',
                onTap: UIActionTrigger(action: Action.clearCart),
              ),
            ],
          ),
          body: UIColumn(
            children: [
              // Cart Summary
              UIContainer(
                padding: const UIEdgeInsets.all(16),
                color: 'purple',
                child: UIRow(
                  mainAxisAlignment: UIMainAxisAlignment.spaceBetween,
                  children: [
                    UIText(
                      text: 'Cart: ${state[State.cart].length} items',
                      color: 'white',
                      fontSize: 16,
                      fontWeight: UIFontWeight.bold,
                    ),
                    UIText(
                      text: 'Total: \$${state[State.totalPrice]}',
                      color: 'white',
                      fontSize: 16,
                      fontWeight: UIFontWeight.bold,
                    ),
                  ],
                ),
              ),

              const UIDivider(height: 1),

              // Action Buttons
              UIContainer(
                padding: const UIEdgeInsets.all(16),
                child: UIRow(
                  mainAxisAlignment: UIMainAxisAlignment.spaceEvenly,
                  children: [
                    UIButton(
                      text: 'Load Products',
                      buttonType: UIButtonType.elevated,
                      onTap: UIActionTrigger(action: Action.fetchProducts),
                    ),
                    UIButton(
                      text: 'Clear Cart',
                      buttonType: UIButtonType.outlined,
                      onTap: UIActionTrigger(action: Action.clearCart),
                    ),
                  ],
                ),
              ),

              const UIDivider(height: 1),

              // Products Grid
              UIExpanded(
                child: UIGridView(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  shrinkWrap: false,
                  itemCount: state[State.products].length.toString(),
                  itemBuilder: UICard(
                    child: UIColumn(
                      mainAxisAlignment: UIMainAxisAlignment.spaceBetween,
                      children: [
                        // Product Image
                        UIContainer(
                          height: 100,
                          child: UIImage(
                            src: state[State.products][index]['image']
                                .toString(),
                            fit: UIBoxFit.contain,
                          ),
                        ),

                        const UISizedBox(height: 8),

                        // Product Name
                        UIContainer(
                          padding: const UIEdgeInsets.symmetric(horizontal: 8),
                          child: UIText(
                            text: state[State.products][index]['title']
                                .toString(),
                            fontSize: 14,
                            fontWeight: UIFontWeight.bold,
                            maxLines: 2,
                          ),
                        ),

                        const UISizedBox(height: 4),

                        // Price
                        UIText(
                          text:
                              '\$${state[State.products][index]['price'].toString()}',
                          fontSize: 16,
                          color: 'purple',
                          fontWeight: UIFontWeight.bold,
                        ),

                        const UISizedBox(height: 8),

                        // Add to Cart Button
                        UIContainer(
                          padding: const UIEdgeInsets.all(8),
                          child: UIButton(
                            text: 'Add to Cart',
                            buttonType: UIButtonType.elevated,
                            onTap: UIActionTrigger(
                              action: Action.addToCart,
                              params: {'index': index},
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).toJson(),
      );
}

/// Extension to compile the DSL program to JSON string
extension StoreMiniAppCompiler on StoreMiniApp {
  /// Compile the DSL program to JSON format
  String compileToJson() {
    final json = program.toJson();
    return const JsonEncoder.withIndent('  ').convert(json);
  }
}

/// Main entry point for compilation
/// Run: dart lib/store_ui.dart
void main() {
  const app = StoreMiniApp();
  final json = app.compileToJson();
  print(json);
}
