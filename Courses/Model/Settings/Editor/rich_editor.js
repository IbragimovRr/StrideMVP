
const FontAttributor = Quill.import('attributors/class/font');

FontAttributor.whitelist = [
    'Montserrat',
    'Attractive',
    'Dots',
    'Sans',
    'Inter',
    'Raleway',
    'Baskerville',
    'MarkerFelt',
    'Cochin',
    'DINCondensed',
    'Palatino',
    'Rockwell',
    'Copperplate',
    'Commissioner',
    'Courier New'
];

Quill.register(FontAttributor, true);

var quill = new Quill('#editor', {
    modules: {}
});


window.QuillFunctions = {
    
    // Получить содержимое редактора
    getEditorContent: function() {
        return quill.root.innerHTML;
    },

    // Установить содержимое редактора
    setEditorContent: function(content) {
        quill.root.innerHTML = content;
    },

    // Установить шрифт
    setFont: function(font) {
        quill.format('font', font);
    },

    // Установить размер шрифта
    setFontSize: function(size) {
        quill.format('size', size);
    },

    // Установить цвет текста
    setTextColor: function(color) {
        quill.format('color', color);
    },

    setBlockquote: function() {
        const format = quill.getFormat();
        quill.format('blockquote', !format.blockquote);
    },

    // Вставить текст
    insertText: function(text) {
        const range = quill.getSelection();
        if (range) {
            quill.insertText(range.index, text);
        }
    },

    // Очистить редактор
    clearEditor: function() {
        quill.setText('');
    },
    
    insertImage: function(imageUrl) {
        const range = quill.getSelection();
        if (range) {
            quill.insertEmbed(range.index, 'image', imageUrl, 'user', {
                style: 'max-width: 100%; height: auto; display: block;'
            });
        } else {
            quill.insertEmbed(0, 'image', imageUrl, 'user', {
                style: 'max-width: 100%; height: auto; display: block;'
            });
        }
    },
    
    // Жирный текст
    toggleBold: function() {
        quill.format('bold', !quill.getFormat().bold);
    },

    // Курсив
    toggleItalic: function() {
        quill.format('italic', !quill.getFormat().italic);
    },

    // Подчеркивание
    toggleUnderline: function() {
        quill.format('underline', !quill.getFormat().underline);
    },

    // Зачеркивание
    toggleStrike: function() {
        quill.format('strike', !quill.getFormat().strike);
    },
    
    setHeading: function(level) {
        quill.format('header', level);
    },

    removeHeading: function() {
        quill.format('header', false);
    },
    
    setAlignment: function(alignment) {
        quill.format('align', alignment);
    },
    
    setupImageClickHandler: function() {
        document.querySelector('.ql-editor').addEventListener('click', function(event) {
            if (event.target.tagName === 'IMG') {
                const imageUrl = event.target.src;
                window.webkit.messageHandlers.imageClicked.postMessage(imageUrl);
            }
        });
    },
    
    setupSelectionChangeHandler: function() {
        quill.on('selection-change', function(range) {
            if (range) {
                const format = quill.getFormat();

                const formattingData = {
                    bold: format.bold || false,
                    italic: format.italic || false,
                    underline: format.underline || false,
                    strike: format.strike || false,
                    blockquote: format.blockquote || false,
                    align: format.align || 'left',
                    font: format.font || 'sans-serif',
                    color: format.color || '#000000',
                    size: format.size || '12pt'
                };

                window.webkit.messageHandlers.format.postMessage(formattingData);
            } else {
                window.webkit.messageHandlers.format.postMessage(null);
            }
        });
    }
    
};
