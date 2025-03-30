
// bookings.js - Script cho trang bookings

document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.dropdown-btn').forEach(btn => {
        btn.addEventListener('click', function (e) {
            e.preventDefault();
            e.stopPropagation();
            const dropdownContent = this.nextElementSibling;
            const isVisible = dropdownContent.style.display === 'block';
            document.querySelectorAll('.dropdown-content').forEach(content => content.style.display = 'none');
            dropdownContent.style.display = isVisible ? 'none' : 'block';
        });
    });
    document.addEventListener('click', function (e) {
        if (!e.target.closest('.dropdown')) {
            document.querySelectorAll('.dropdown-content').forEach(content => content.style.display = 'none');
        }
    });
});

function updateStatus(bookingId, status) {
    const lang = '<%= language%>';
    const message = lang === 'vi' ? (status === 'Confirmed' ? 'Bạn có chắc chắn muốn xác nhận đặt phòng này không?' : 'Bạn có chắc chắn muốn hủy đặt phòng này không?')
            : `Are you sure you want to ${status.toLowerCase()} this booking?`;
    if (confirm(message)) {
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = '<%= request.getContextPath()%>/admin/bookings/update';
        form.innerHTML = `<input type="hidden" name="bookingId" value="${bookingId}">
                          <input type="hidden" name="status" value="${status}">`;
        document.body.appendChild(form);
        form.submit();
    }
}