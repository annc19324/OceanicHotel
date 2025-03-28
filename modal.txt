// assets/js/modal.js

// Đóng modal
export function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.remove('active');
        setTimeout(() => modal.style.display = 'none', 300); // Chờ animation hoàn tất
    } else {
        console.error(`Modal with ID ${modalId} not found`);
    }
}

// Hiển thị modal với hiệu ứng
export function showModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.style.display = 'flex';
        setTimeout(() => modal.classList.add('active'), 10); // Thêm class sau khi display để chạy animation
    } else {
        console.error(`Modal with ID ${modalId} not found`);
    }
}

// Hiển thị modal xác nhận
export function showConfirmModal(action, userId, contextPath = window.contextPath, language = window.language) {
    console.log('showConfirmModal called with:', { action, userId, contextPath, language });
    const modal = document.getElementById('confirmModal');
    const message = document.getElementById('confirmMessage');
    const yesBtn = document.getElementById('confirmYes');

    if (!modal || !message || !yesBtn) {
        console.error('Modal elements not found');
        return;
    }

    if (action === 'delete') {
        message.textContent = language === 'vi' ? 'Bạn có chắc chắn muốn xóa người dùng này không?' : 'Are you sure you want to delete this user?';
        yesBtn.onclick = function() {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = `${contextPath}/admin/users/delete`;
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'userId';
            input.value = userId;
            form.appendChild(input);
            document.body.appendChild(form);
            form.submit();
        };
    } else if (action === 'edit') {
        message.textContent = language === 'vi' ? 'Bạn có chắc chắn muốn chỉnh sửa thông tin người dùng này không?' : 'Are you sure you want to edit this user\'s information?';
        yesBtn.onclick = function() {
            window.location.href = `${contextPath}/admin/users/edit?userId=${userId}`;
        };
    }

    showModal('confirmModal');
}

// Tự động hiển thị notification modal nếu có
export function initNotificationModal() {
    if (document.getElementById('notificationModal')) {
        showModal('notificationModal');
    }
}

// Khởi tạo modal khi trang tải
document.addEventListener('DOMContentLoaded', () => {
    initNotificationModal();
});