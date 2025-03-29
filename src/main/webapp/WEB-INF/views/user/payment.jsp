<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Oceanic Hotel - Thanh toán</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/reset.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/variables.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/button.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/container.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/form.css">
</head>
<body>
    <header class="header">
        <!-- Same header as dashboard -->
    </header>

    <main class="main">
        <section class="payment-process">
            <div class="container">
                <div class="process-steps">
                    <div class="step completed">1. Thông tin đặt phòng</div>
                    <div class="step active">2. Thanh toán</div>
                    <div class="step">3. Xác nhận</div>
                </div>
                
                <div class="payment-content">
                    <div class="payment-summary">
                        <h2>Thông tin đặt phòng</h2>
                        <div class="booking-info">
                            <p><strong>Phòng:</strong> ${room.number} - ${room.typeName}</p>
                            <p><strong>Ngày nhận phòng:</strong> ${booking.checkInDate}</p>
                            <p><strong>Ngày trả phòng:</strong> ${booking.checkOutDate}</p>
                            <p><strong>Số đêm:</strong> ${nights}</p>
                            <p><strong>Số người:</strong> ${booking.adults} người lớn, ${booking.children} trẻ em</p>
                            <p class="price"><strong>Tổng cộng:</strong> ${booking.totalPrice} VND</p>
                        </div>
                    </div>
                    
                    <div class="payment-form">
                        <h2>Phương thức thanh toán</h2>
                        <form action="${pageContext.request.contextPath}/payment/process" method="post" id="paymentForm">
                            <input type="hidden" name="bookingId" value="${booking.id}">
                            
                            <div class="payment-methods">
                                <div class="payment-method">
                                    <input type="radio" id="credit-card" name="paymentMethod" value="credit-card" checked>
                                    <label for="credit-card">Thẻ tín dụng/Thẻ ghi nợ</label>
                                </div>
                                <div class="payment-method">
                                    <input type="radio" id="bank-transfer" name="paymentMethod" value="bank-transfer">
                                    <label for="bank-transfer">Chuyển khoản ngân hàng</label>
                                </div>
                                <div class="payment-method">
                                    <input type="radio" id="paypal" name="paymentMethod" value="paypal">
                                    <label for="paypal">PayPal</label>
                                </div>
                            </div>
                            
                            <div class="credit-card-form" id="creditCardForm">
                                <div class="form-group">
                                    <label for="cardNumber">Số thẻ</label>
                                    <input type="text" id="cardNumber" name="cardNumber" placeholder="1234 5678 9012 3456">
                                </div>
                                
                                <div class="form-group">
                                    <label for="cardName">Tên trên thẻ</label>
                                    <input type="text" id="cardName" name="cardName" placeholder="NGUYEN VAN A">
                                </div>
                                
                                <div class="form-row">
                                    <div class="form-group">
                                        <label for="expiryDate">Ngày hết hạn</label>
                                        <input type="text" id="expiryDate" name="expiryDate" placeholder="MM/YY">
                                    </div>
                                    <div class="form-group">
                                        <label for="cvv">CVV</label>
                                        <input type="text" id="cvv" name="cvv" placeholder="123">
                                    </div>
                                </div>
                            </div>
                            
                            <div class="bank-transfer-form" id="bankTransferForm" style="display: none;">
                                <p>Vui lòng chuyển khoản đến tài khoản sau:</p>
                                <p><strong>Ngân hàng:</strong> Oceanic Bank</p>
                                <p><strong>Số tài khoản:</strong> 123456789</p>
                                <p><strong>Tên tài khoản:</strong> Oceanic Hotel</p>
                                <p><strong>Số tiền:</strong> ${booking.totalPrice} VND</p>
                                <p><strong>Nội dung:</strong> BOOKING_${booking.id}</p>
                            </div>
                            
                            <div class="paypal-form" id="paypalForm" style="display: none;">
                                <p>Bạn sẽ được chuyển hướng đến trang thanh toán PayPal sau khi xác nhận.</p>
                            </div>
                            
                            <div class="form-actions">
                                <a href="${pageContext.request.contextPath}/booking?roomId=${room.id}" class="btn btn-outline">Quay lại</a>
                                <button type="submit" class="btn btn-primary">Hoàn tất thanh toán</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </section>
    </main>

    <footer class="footer">
        <!-- Same footer as dashboard -->
    </footer>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const paymentMethods = document.querySelectorAll('input[name="paymentMethod"]');
            const creditCardForm = document.getElementById('creditCardForm');
            const bankTransferForm = document.getElementById('bankTransferForm');
            const paypalForm = document.getElementById('paypalForm');
            
            paymentMethods.forEach(method => {
                method.addEventListener('change', function() {
                    creditCardForm.style.display = 'none';
                    bankTransferForm.style.display = 'none';
                    paypalForm.style.display = 'none';
                    
                    if (this.value === 'credit-card') {
                        creditCardForm.style.display = 'block';
                    } else if (this.value === 'bank-transfer') {
                        bankTransferForm.style.display = 'block';
                    } else if (this.value === 'paypal') {
                        paypalForm.style.display = 'block';
                    }
                });
            });
        });
    </script>
</body>
</html>