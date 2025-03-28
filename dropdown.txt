// assets/js/dropdown.js

// Xử lý dropdown
export function initDropdown() {
    document.querySelectorAll('.dropdown-btn').forEach(btn => {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            const dropdownContent = this.nextElementSibling;
            const isVisible = dropdownContent.style.display === 'block';
            document.querySelectorAll('.dropdown-content').forEach(content => {
                content.style.display = 'none';
            });
            dropdownContent.style.display = isVisible ? 'none' : 'block';
        });
    });

    document.addEventListener('click', function(e) {
        if (!e.target.classList.contains('dropdown-btn')) {
            document.querySelectorAll('.dropdown-content').forEach(content => {
                content.style.display = 'none';
            });
        }
    });
}

// Khởi tạo dropdown khi trang tải
document.addEventListener('DOMContentLoaded', () => {
    initDropdown();
});