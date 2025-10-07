import 'package:get/get.dart';
import 'package:topgrade/utils/helpers/snackbars.dart';
import '../../data/model/carousel_response_model.dart';
import '../../data/source/remote_source.dart';

class CarouselController extends GetxController {
  final RemoteSource _remoteSource = Get.find<RemoteSourceImpl>();

  // Observable variables
  final RxBool _isLoading = true.obs;
  final RxList<CarouselSlide> _carouselSlides = <CarouselSlide>[].obs;
  final RxInt _currentIndex = 0.obs;

  // Getters
  RxBool get isLoading => _isLoading;
  RxList<CarouselSlide> get carouselSlides => _carouselSlides;
  RxInt get currentIndex => _currentIndex;

  @override
  void onInit() {
    super.onInit();
    fetchCarouselData();
  }

  /// Fetch carousel data from API
  Future<void> fetchCarouselData() async {
    try {
      _isLoading.value = true;
      
      final CarouselResponseModel response = await _remoteSource.getCarouselData();
      
      if (response.success && response.data.isNotEmpty) {
        _carouselSlides.assignAll(response.data);
      } else {
        _carouselSlides.clear();
      }
    } catch (e) {
      _carouselSlides.clear();
      Snackbars.errorSnackBar('Failed to load carousel: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Update current carousel index
  void updateCurrentIndex(int index) {
    _currentIndex.value = index;
  }

  /// Refresh carousel data
  Future<void> refreshCarouselData() async {
    await fetchCarouselData();
  }
}