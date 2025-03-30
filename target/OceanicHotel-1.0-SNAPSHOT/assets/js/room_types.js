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

function confirmDelete(typeId) {
    const lang = '<%= language%>';
    const message = lang === 'vi' ? 'Bạn có chắc chắn muốn xóa loại phòng này không?' : 'Are you sure you want to delete this room type?';
    if (confirm(message)) {
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = '<%= request.getContextPath()%>/admin/room-types/delete';
        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = 'typeId';
        input.value = typeId;
        form.appendChild(input);
        document.body.appendChild(form);
        form.submit();
    }
}