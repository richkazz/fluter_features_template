import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import '../models/product.dart';
import '../repository/store_repository.dart';

part 'store_event.dart';
part 'store_state.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  StoreBloc() : super(const StoreState()) {
    on<StoreProductsRequested>(_handleStoreProductsRequested);
    on<StoreProductsAddedToCart>(_handleStoreProductsAddedToCart);
    on<StoreProductsRemovedFromCart>(_handleStoreProductsRemovedFromCart);
  }

  final StoreRepository api = StoreRepository();

  Future<void> _handleStoreProductsRequested(
    StoreProductsRequested event,
    Emitter<StoreState> emit,
  ) async {
    try {
      emit(state.copyWith(
        productsStatus: StoreRequest.requestInProgress,
      ));

      final response = await api.getProducts();

      emit(state.copyWith(
        productsStatus: StoreRequest.requestSuccess,
        products: response,
      ));
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(state.copyWith(
        productsStatus: StoreRequest.requestFailure,
      ));
    }
  }

  Future<void> _handleStoreProductsAddedToCart(
    StoreProductsAddedToCart event,
    Emitter<StoreState> emit,
  ) async {
    emit(state.copyWith(cartIds: {...state.cartIds, event.cartId}));
  }

  Future<void> _handleStoreProductsRemovedFromCart(
    StoreProductsRemovedFromCart event,
    Emitter<StoreState> emit,
  ) async {
    emit(state.copyWith(cartIds: {...state.cartIds}..remove(event.cartId)));
  }
}
