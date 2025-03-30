<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="${sessionScope.language}">
<head>
    <meta charset="UTF-8">
    <title>${sessionScope.language == 'vi' ? 'Oceanic Hotel - Thanh toán' : 'Oceanic Hotel - Payment'}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/reset.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/variables.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/button.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/container.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/form.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/partials/header.jsp" />

    <main class="main">
        <section class="payment-process">
            <div class="container">
                <div class="process-steps">
                    <div class="step completed">1. ${sessionScope.language == 'vi' ? 'Thông tin đặt phòng' : 'Booking Info'}</div>
                    <div class="step active">2. ${sessionScope.language == 'vi' ? 'Thanh toán' : 'Payment'}</div>
                    <div class="step">3. ${sessionScope.language == 'vi' ? 'Xác nhận' : 'Confirmation'}</div>
                </div>
                
                <div class="payment-content">
                    <div class="payment-summary">
                        <h2>${sessionScope.language == 'vi' ? 'Thông tin đặt phòng' : 'Booking Information'}</h2>
                        <div class="booking-info">
                            <p><strong>${sessionScope.language == 'vi' ? 'Phòng' : 'Room'}:</strong> ${booking.room.roomNumber} - ${booking.room.roomType.typeName}</p>
                            <p><strong>${sessionScope.language == 'vi' ? 'Ngày nhận phòng' : 'Check-in'}:</strong> ${booking.checkInDate}</p>
                            <p><strong>${sessionScope.language == 'vi' ? 'Ngày trả phòng' : 'Check-out'}:</strong> ${booking.checkOutDate}</p>
                            <p><strong>${sessionScope.language == 'vi' ? 'Số đêm' : 'Nights'}:</strong> ${nights}</p>
                            <p><strong>${sessionScope.language == 'vi' ? 'Số người' : 'Guests'}:</strong> ${booking.adults} ${sessionScope.language == 'vi' ? 'người lớn' : 'adults'}, ${booking.children} ${sessionScope.language == 'vi' ? 'trẻ em' : 'children'}</p>
                            <p class="price"><strong>${sessionScope.language == 'vi' ? 'Tổng cộng' : 'Total'}:</strong> ${booking.totalPrice} VND</p>
                        </div>
                    </div>
                    
                    <div class="payment-form">
                        <h2>${sessionScope.language == 'vi' ? 'Phương thức thanh toán' : 'Payment Method'}</h2>
                        <form action="${pageContext.request.contextPath}/user/payment/process" method="post" id="paymentForm">
                            <input type="hidden" name="bookingId" value="${booking.bookingId}">
                            
                            <div class="payment-methods">
                                <div class="payment-method">
                                    <input type="radio" id="credit-card" name="paymentMethod" value="credit-card" checked>
                                    <label for="credit-card">${sessionScope.language == 'vi' ? 'Thẻ tín dụng/Thẻ ghi nợ' : 'Credit/Debit Card'}</label>
                                </div>
                                <div class="payment-method">
                                    <input type="radio" id="bank-transfer" name="paymentMethod" value="bank-transfer">
                                    <label for="bank-transfer">${sessionScope.language == 'vi' ? 'Chuyển khoản ngân hàng' : 'Bank Transfer'}</label>
                                </div>
                                <div class="payment-method">
                                    <input type="radio" id="paypal" name="paymentMethod" value="paypal">
                                    <label for="paypal">PayPal</label>
                                </div>
                            </div>
                            
                            <div class="credit-card-form" id="creditCardForm">
                                <div class="form-group">
                                    <label for="cardNumber">${sessionScope.language == 'vi' ? 'Số thẻ' : 'Card Number'}</label>
                                    <input type="text" id="cardNumber" name="cardNumber" placeholder="1234 5678 9012 3456">
                                </div>
                                
                                <div class="form-group">
                                    <label for="cardName">${sessionScope.language == 'vi' ? 'Tên trên thẻ' : 'Cardholder Name'}</label>
                                    <input type="text" id="cardName" name="cardName" placeholder="NGUYEN VAN A">
                                </div>
                                
                                <div class="form-row">
                                    <div class="form-group">
                                        <label for="expiryDate">${sessionScope.language == 'vi' ? 'Ngày hết hạn' : 'Expiry Date'}</label>
                                        <input type="text" id="expiryDate" name="expiryDate" placeholder="MM/YY">
                                    </div>
                                    <div class="form-group">
                                        <label for="cvv">CVV</label>
                                        <input type="text" id="cvv" name="cvv" placeholder="123">
                                    </div>
                                </div>
                            </div>
                            
                            <div class="bank-transfer-form" id="bankTransferForm" style="display: none;">
                                <p>${sessionScope.language == 'vi' ? 'Vui lòng chuyển khoản đến tài khoản sau:' : 'Please transfer to the following account:'}</p>
                                <p><strong>${sessionScope.language == 'vi' ? 'Ngân hàng' : 'Bank'}:</strong> Oceanic Bank</p>
                                <p><strong>${sessionScope.language == 'vi' ? 'Số tài khoản' : 'Account Number'}:</strong> 123456789</p>
                                <p><strong>${sessionScope.language == 'vi' ? 'Tên tài khoản' : 'Account Name'}:</strong> Oceanic Hotel</p>
                                <p><strong>${sessionScope.language == 'vi' ? 'Số tiền' : 'Amount'}:</strong> ${booking.totalPrice} VND</p>
                                <p><strong>${sessionScope.language == 'vi' ? 'Nội dung' : 'Description'}:</strong> BOOKING_${booking.bookingId}</p>
                            </div>
                            
                            <div class="paypal-form" id="paypalForm" style="display: none;">
                                <p>${sessionScope.language == 'vi' ? 'Bạn sẽ được chuyển hướng đến PayPal sau khi xác nhận.' : 'You will be redirected to PayPal after confirmation.'}</p>
                            </div>
                            
                            <div class="form-actions">
                                <a href="${pageContext.request.contextPath}/user/booking?roomId=${booking.roomId}" class="btn btn-outline">${sessionScope.language == 'vi' ? 'Quay lại' : 'Back'}</a>
                                <button type="submit" class="btn btn-primary">${sessionScope.language == 'vi' ? 'Hoàn tất thanh toán' : 'Complete Payment'}</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </section>
    </main>

    <jsp:include page="/WEB-INF/views/partials/footer.jsp" />

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