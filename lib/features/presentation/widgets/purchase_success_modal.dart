import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/model/purchase_response_model.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/fonts.dart';
import '../../../utils/constants/sizes.dart';

class PurchaseSuccessModal extends StatefulWidget {
  final PurchaseResponseModel purchaseResponse;
  final VoidCallback onContinue;

  const PurchaseSuccessModal({
    super.key,
    required this.purchaseResponse,
    required this.onContinue,
  });

  @override
  State<PurchaseSuccessModal> createState() => _PurchaseSuccessModalState();
}

class _PurchaseSuccessModalState extends State<PurchaseSuccessModal>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  
  late Animation<double> _celebrationAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _celebrationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    // Initialize animations
    _celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Start animations sequentially
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(Duration(milliseconds: 100));
    _slideController.forward();
    
    await Future.delayed(Duration(milliseconds: 200));
    _scaleController.forward();
    
    await Future.delayed(Duration(milliseconds: 300));
    _celebrationController.forward();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            margin: EdgeInsets.all(XSizes.marginLg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(XSizes.borderRadiusLg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Celebration Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(XSizes.paddingLg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        XColors.primaryColor,
                        XColors.primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(XSizes.borderRadiusLg),
                      topRight: Radius.circular(XSizes.borderRadiusLg),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Animated Success Icon
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: AnimatedBuilder(
                            animation: _celebrationAnimation,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _celebrationAnimation.value * 0.2,
                                child: Icon(
                                  Icons.check_circle,
                                  size: 50,
                                  color: XColors.primaryColor,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      SizedBox(height: XSizes.spacingMd),
                      
                      // Success Title
                      AnimatedBuilder(
                        animation: _celebrationAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 0.8 + (_celebrationAnimation.value * 0.2),
                            child: Text(
                              '🎉 Purchase Successful! 🎉',
                              style: TextStyle(
                                fontSize: XSizes.textSizeLg,
                                fontFamily: XFonts.lexend,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                      
                      SizedBox(height: XSizes.spacingSm),
                      
                      // Success Message
                      Text(
                        widget.purchaseResponse.message,
                        style: TextStyle(
                          fontSize: XSizes.textSizeSm,
                          fontFamily: XFonts.lexend,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Purchase Details
                Padding(
                  padding: EdgeInsets.all(XSizes.paddingLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Title
                      Text(
                        widget.purchaseResponse.purchase.programTitle,
                        style: TextStyle(
                          fontSize: XSizes.textSizeMd,
                          fontFamily: XFonts.lexend,
                          fontWeight: FontWeight.w600,
                          color: XColors.textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: XSizes.spacingMd),
                      
                      // Purchase Details
                      _buildDetailRow(
                        'Transaction ID',
                        widget.purchaseResponse.purchase.transactionId,
                      ),
                      
                      _buildDetailRow(
                        'Purchase Date',
                        _formatDate(widget.purchaseResponse.purchase.purchaseDate),
                      ),
                      
                      _buildDetailRow(
                        'Status',
                        widget.purchaseResponse.purchase.status.toUpperCase(),
                        valueColor: XColors.primaryColor,
                      ),
                      
                      SizedBox(height: XSizes.spacingMd),
                      
                      // Pricing Details
                      Container(
                        padding: EdgeInsets.all(XSizes.paddingMd),
                        decoration: BoxDecoration(
                          color: XColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
                          border: Border.all(
                            color: XColors.primaryColor.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildPricingRow(
                              'Original Price',
                              '\$${widget.purchaseResponse.pricing.originalPrice.toStringAsFixed(2)}',
                              isStriked: widget.purchaseResponse.pricing.discountPercentage > 0,
                            ),
                            
                            if (widget.purchaseResponse.pricing.discountPercentage > 0) ...[
                              SizedBox(height: XSizes.spacingXs),
                              _buildPricingRow(
                                'Discount (${widget.purchaseResponse.pricing.discountPercentage}%)',
                                '-\$${widget.purchaseResponse.pricing.savings.toStringAsFixed(2)}',
                                valueColor: Colors.green,
                              ),
                              SizedBox(height: XSizes.spacingXs),
                              Divider(color: XColors.primaryColor.withOpacity(0.3)),
                              SizedBox(height: XSizes.spacingXs),
                            ],
                            
                            _buildPricingRow(
                              'Total Paid',
                              '\$${widget.purchaseResponse.pricing.discountedPrice.toStringAsFixed(2)}',
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: XSizes.spacingLg),
                      
                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.onContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: XColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: XSizes.paddingMd),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(XSizes.borderRadiusMd),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Start Learning Now!',
                            style: TextStyle(
                              fontSize: XSizes.textSizeMd,
                              fontFamily: XFonts.lexend,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: XSizes.paddingXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: XSizes.textSizeSm,
              fontFamily: XFonts.lexend,
              color: XColors.textColor.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: XSizes.textSizeSm,
              fontFamily: XFonts.lexend,
              fontWeight: FontWeight.w500,
              color: valueColor ?? XColors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingRow(String label, String value, {
    bool isStriked = false,
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? XSizes.textSizeMd : XSizes.textSizeSm,
            fontFamily: XFonts.lexend,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: isTotal ? XColors.textColor : XColors.textColor.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? XSizes.textSizeMd : XSizes.textSizeSm,
            fontFamily: XFonts.lexend,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? (isTotal ? XColors.primaryColor : XColors.textColor),
            decoration: isStriked ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}