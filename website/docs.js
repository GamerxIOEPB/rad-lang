// ==============================================================================
// Rad Documentation Engine (docs.js)
// Zero-dependency fast Markdown parser, syntax highlighter, and navigator
// ==============================================================================

const DOCS_NAV = [
    {
        group: "Getting Started",
        items: [
            { id: "01_what_is_rad.md", title: "What is Rad?", num: "1" },
            { id: "02_installation.md", title: "Installation & Setup", num: "2" },
            { id: "03_getting_started.md", title: "Getting Started (Hello World)", num: "3" }
        ]
    },
    {
        group: "Language Fundamentals",
        items: [
            { id: "04_variables_and_types.md", title: "Variables & Data Types", num: "4" },
            { id: "05_operators_and_expressions.md", title: "Operators & Expressions", num: "5" },
            { id: "06_control_flow.md", title: "Control Flow (If & While)", num: "6" },
            { id: "07_functions.md", title: "Functions & Main Entry", num: "7" }
        ]
    },
    {
        group: "Data Modeling & Memory",
        items: [
            { id: "08_structs_and_methods.md", title: "Structs & Methods", num: "8" },
            { id: "09_pointers_and_memory.md", title: "Pointers, Memory & Casting", num: "9" },
            { id: "10_strings_and_collections.md", title: "Strings, Collections & I/O", num: "10" }
        ]
    },
    {
        group: "Systems & Interoperability",
        items: [
            { id: "11_c_interop.md", title: "C & C++ Interoperability", num: "11" },
            { id: "12_compiler_cli.md", title: "Compiler (radc) & Linking", num: "12" },
            { id: "13_package_manager.md", title: "Package Manager (rad)", num: "13" }
        ]
    },
    {
        group: "Ecosystem & Tooling",
        items: [
            { id: "14_standard_library.md", title: "Standard Library (core/alloc/std)", num: "14" },
            { id: "15_editor_support.md", title: "VS Code & Tree-Sitter", num: "15" }
        ]
    }
];

// Flat list for Prev/Next navigation
const FLAT_DOCS = [];
DOCS_NAV.forEach(group => {
    group.items.forEach(item => FLAT_DOCS.push({ ...item, group: group.group }));
});

let currentDocId = "01_what_is_rad.md";

// ------------------------------------------------------------------------------
// Markdown Parsing Engine
// ------------------------------------------------------------------------------

function escapeHtml(str) {
    return str
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

function highlightRad(code) {
    const keywords = ["fn", "let", "var", "struct", "if", "else", "while", "return", "as", "pub", "break", "continue", "const", "true", "false", "import"];
    const types = ["i8", "i16", "i32", "i64", "isize", "u8", "u16", "u32", "u64", "usize", "f32", "f64", "bool", "str", "void", "String", "Vec", "Option", "Result"];

    let lines = code.split("\n");
    let out = [];

    for (let line of lines) {
        // Line comment
        if (line.trim().startsWith("//")) {
            out.push(`<span class="token-comment">${escapeHtml(line)}</span>`);
            continue;
        }

        let escaped = escapeHtml(line);

        // Highlight strings
        escaped = escaped.replace(/(".*?")/g, '<span class="token-string">$1</span>');

        // Highlight numbers
        escaped = escaped.replace(/\b(\d+([uif]\d+|usize|isize)?)\b/g, '<span class="token-number">$1</span>');

        // Highlight types
        types.forEach(t => {
            let re = new RegExp(`\\b(${t})\\b`, "g");
            escaped = escaped.replace(re, '<span class="token-type">$1</span>');
        });

        // Highlight keywords
        keywords.forEach(kw => {
            let re = new RegExp(`\\b(${kw})\\b`, "g");
            escaped = escaped.replace(re, '<span class="token-keyword">$1</span>');
        });

        // Highlight function calls: name(
        escaped = escaped.replace(/\b([a-zA-Z_][a-zA-Z0-9_]*)(?=\s*\()/g, '<span class="token-function">$1</span>');

        out.push(escaped);
    }

    return out.join("\n");
}

function parseMarkdown(md) {
    let lines = md.split("\n");
    let html = [];
    let toc = [];
    let inCodeBlock = false;
    let codeLang = "";
    let codeLines = [];
    let inTable = false;
    let tableLines = [];
    let inList = false;
    let listType = "ul";

    function flushList() {
        if (inList) {
            html.push(`</${listType}>`);
            inList = false;
        }
    }

    function flushTable() {
        if (inTable && tableLines.length > 0) {
            let tableHtml = "<table>";
            let headers = tableLines[0].split("|").map(s => s.trim()).filter(s => s.length > 0);
            tableHtml += "<thead><tr>";
            headers.forEach(h => tableHtml += `<th>${parseInline(h)}</th>`);
            tableHtml += "</tr></thead><tbody>";

            for (let i = 2; i < tableLines.length; i++) {
                let cells = tableLines[i].split("|").map(s => s.trim()).filter(s => s.length > 0);
                if (cells.length > 0) {
                    tableHtml += "<tr>";
                    cells.forEach(c => tableHtml += `<td>${parseInline(c)}</td>`);
                    tableHtml += "</tr>";
                }
            }

            tableHtml += "</tbody></table>";
            html.push(tableHtml);
            inTable = false;
            tableLines = [];
        }
    }

    function parseInline(text) {
        let t = text;
        // Inline code `code`
        t = t.replace(/`([^`]+)`/g, (m, c) => `<code>${escapeHtml(c)}</code>`);
        // Bold **text**
        t = t.replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>");
        // Italic *text*
        t = t.replace(/\*([^*]+)\*/g, "<em>$1</em>");
        // Links [text](url)
        t = t.replace(/\[([^\]]+)\]\(([^)]+)\)/g, (m, txt, url) => {
            if (url.startsWith("#") || url.endsWith(".md")) {
                let docTarget = url.replace(/\.md$/, "");
                return `<a href="#${docTarget}" class="doc-link">${txt}</a>`;
            }
            return `<a href="${url}" target="_blank" rel="noopener noreferrer">${txt}</a>`;
        });
        return t;
    }

    for (let i = 0; i < lines.length; i++) {
        let line = lines[i];

        // Code block toggle
        if (line.trim().startsWith("```")) {
            flushList();
            flushTable();
            if (!inCodeBlock) {
                inCodeBlock = true;
                codeLang = line.trim().slice(3).trim();
                codeLines = [];
            } else {
                inCodeBlock = false;
                let rawCode = codeLines.join("\n");
                let highlighted = (codeLang === "rad" || codeLang === "") 
                    ? highlightRad(rawCode) 
                    : escapeHtml(rawCode);
                
                let langLabel = codeLang.toUpperCase() || "RAD";
                let blockId = "code-" + Math.random().toString(36).substr(2, 8);
                
                html.push(`
                    <div class="code-block-wrapper">
                        <div class="code-header">
                            <span>${langLabel}</span>
                            <button class="copy-btn" onclick="copyCodeBlock('${blockId}')">Copy</button>
                        </div>
                        <pre><code id="${blockId}">${highlighted}</code></pre>
                    </div>
                `);
            }
            continue;
        }

        if (inCodeBlock) {
            codeLines.push(line);
            continue;
        }

        // Table detection
        if (line.trim().startsWith("|") && line.trim().endsWith("|")) {
            flushList();
            if (!inTable) {
                inTable = true;
                tableLines = [line];
            } else {
                tableLines.push(line);
            }
            continue;
        } else if (inTable) {
            flushTable();
        }

        // Callout alerts: > [!NOTE], > [!TIP], > [!WARNING], > [!IMPORTANT]
        if (line.trim().startsWith("> [!")) {
            flushList();
            let alertType = "note";
            let alertTitle = "Note";
            if (line.includes("TIP")) { alertType = "tip"; alertTitle = "Tip"; }
            else if (line.includes("WARNING")) { alertType = "warning"; alertTitle = "Warning"; }
            else if (line.includes("IMPORTANT")) { alertType = "warning"; alertTitle = "Important"; }

            let alertContent = [];
            let j = i + 1;
            while (j < lines.length && lines[j].trim().startsWith(">")) {
                alertContent.push(lines[j].trim().slice(1).trim());
                j++;
            }
            i = j - 1;

            html.push(`
                <div class="callout callout-${alertType}">
                    <div class="callout-title">${alertTitle}</div>
                    <p>${parseInline(alertContent.join(" "))}</p>
                </div>
            `);
            continue;
        }

        // Headings
        if (line.startsWith("# ")) {
            flushList();
            let text = line.slice(2).trim();
            let id = text.toLowerCase().replace(/[^a-z0-9]+/g, "-");
            html.push(`<h1 id="${id}">${parseInline(text)}</h1>`);
            continue;
        }
        if (line.startsWith("## ")) {
            flushList();
            let text = line.slice(3).trim();
            let id = text.toLowerCase().replace(/[^a-z0-9]+/g, "-");
            html.push(`<h2 id="${id}">${parseInline(text)}</h2>`);
            toc.push({ level: 2, text: text, id: id });
            continue;
        }
        if (line.startsWith("### ")) {
            flushList();
            let text = line.slice(4).trim();
            let id = text.toLowerCase().replace(/[^a-z0-9]+/g, "-");
            html.push(`<h3 id="${id}">${parseInline(text)}</h3>`);
            toc.push({ level: 3, text: text, id: id });
            continue;
        }
        if (line.startsWith("#### ")) {
            flushList();
            let text = line.slice(5).trim();
            html.push(`<h4>${parseInline(text)}</h4>`);
            continue;
        }

        // Horizontal Rule
        if (line.trim() === "---" || line.trim() === "***") {
            flushList();
            html.push("<hr />");
            continue;
        }

        // Unordered List
        if (line.trim().startsWith("- ") || line.trim().startsWith("* ")) {
            if (!inList || listType !== "ul") {
                flushList();
                inList = true;
                listType = "ul";
                html.push("<ul>");
            }
            let itemText = line.trim().slice(2);
            html.push(`<li>${parseInline(itemText)}</li>`);
            continue;
        }

        // Ordered List
        if (/^\d+\.\s/.test(line.trim())) {
            if (!inList || listType !== "ol") {
                flushList();
                inList = true;
                listType = "ol";
                html.push("<ol>");
            }
            let itemText = line.trim().replace(/^\d+\.\s/, "");
            html.push(`<li>${parseInline(itemText)}</li>`);
            continue;
        }

        // Empty line
        if (line.trim().length === 0) {
            flushList();
            continue;
        }

        // Standard Paragraph
        flushList();
        html.push(`<p>${parseInline(line)}</p>`);
    }

    flushList();
    flushTable();

    return {
        html: html.join("\n"),
        toc: toc
    };
}

// ------------------------------------------------------------------------------
// Document Rendering & Navigation
// ------------------------------------------------------------------------------

async function loadChapter(docId) {
    currentDocId = docId;
    window.location.hash = docId.replace(/\.md$/, "");

    let rawMarkdown = "";

    // 1. Check embedded dictionary
    if (window.RAD_DOCS && window.RAD_DOCS[docId]) {
        rawMarkdown = window.RAD_DOCS[docId];
    } else {
        // 2. Fetch from filesystem or server
        try {
            let res = await fetch("docs/" + docId);
            if (res.ok) {
                rawMarkdown = await res.text();
            } else {
                rawMarkdown = `# Chapter Not Found\n\nCould not load \`${docId}\`.`;
            }
        } catch (e) {
            rawMarkdown = `# Error\n\nFailed to load chapter content for \`${docId}\`.`;
        }
    }

    // Parse and render
    let { html, toc } = parseMarkdown(rawMarkdown);

    // Update main content
    const contentEl = document.getElementById("docs-content");
    contentEl.innerHTML = html;

    // Update active sidebar link
    document.querySelectorAll(".sidebar-nav-link").forEach(link => {
        if (link.getAttribute("data-id") === docId) {
            link.classList.add("active");
            link.scrollIntoView({ block: "nearest", behavior: "smooth" });
        } else {
            link.classList.remove("active");
        }
    });

    // Update breadcrumbs
    let currentItem = FLAT_DOCS.find(d => d.id === docId);
    if (currentItem) {
        document.getElementById("breadcrumb-group").innerText = currentItem.group;
        document.getElementById("breadcrumb-title").innerText = currentItem.title;
        document.title = `${currentItem.title} — Rad Programming Language Documentation`;
    }

    // Render Right TOC ("On This Page")
    renderToc(toc);

    // Render Navigation Footer (Prev / Next)
    renderNavFooter(docId);

    // Scroll to top
    window.scrollTo({ top: 0, behavior: "smooth" });

    // Close mobile drawer if open
    document.getElementById("docs-sidebar").classList.remove("open");
}

function renderToc(toc) {
    const tocContainer = document.getElementById("toc-list");
    if (!tocContainer) return;

    if (toc.length === 0) {
        tocContainer.innerHTML = '<li class="toc-item"><span class="toc-link" style="color:var(--text-muted)">No subsections</span></li>';
        return;
    }

    let tocHtml = toc.map(item => `
        <li class="toc-item h${item.level}">
            <a href="#${item.id}" class="toc-link" onclick="scrollToHeading('${item.id}', event)">${escapeHtml(item.text)}</a>
        </li>
    `).join("");

    tocContainer.innerHTML = tocHtml;
}

function scrollToHeading(id, e) {
    if (e) e.preventDefault();
    const el = document.getElementById(id);
    if (el) {
        const top = el.getBoundingClientRect().top + window.scrollY - 80;
        window.scrollTo({ top: top, behavior: "smooth" });
        history.pushState(null, null, `#${currentDocId.replace(/\.md$/, "")}#${id}`);
    }
}

function renderNavFooter(docId) {
    const footerContainer = document.getElementById("docs-nav-footer");
    if (!footerContainer) return;

    let idx = FLAT_DOCS.findIndex(d => d.id === docId);
    if (idx === -1) return;

    let prevDoc = idx > 0 ? FLAT_DOCS[idx - 1] : null;
    let nextDoc = idx < FLAT_DOCS.length - 1 ? FLAT_DOCS[idx + 1] : null;

    let html = "";

    if (prevDoc) {
        html += `
            <a href="#${prevDoc.id.replace(/\.md$/, "")}" class="docs-nav-card prev" onclick="loadChapter('${prevDoc.id}'); return false;">
                <span class="card-dir">← Previous</span>
                <span class="card-title">${prevDoc.title}</span>
            </a>
        `;
    } else {
        html += `<div></div>`;
    }

    if (nextDoc) {
        html += `
            <a href="#${nextDoc.id.replace(/\.md$/, "")}" class="docs-nav-card next" onclick="loadChapter('${nextDoc.id}'); return false;">
                <span class="card-dir">Next →</span>
                <span class="card-title">${nextDoc.title}</span>
            </a>
        `;
    }

    footerContainer.innerHTML = html;
}

function copyCodeBlock(id) {
    const codeEl = document.getElementById(id);
    if (!codeEl) return;
    const text = codeEl.innerText;
    navigator.clipboard.writeText(text).then(() => {
        const btn = codeEl.closest(".code-block-wrapper").querySelector(".copy-btn");
        if (btn) {
            btn.innerText = "Copied!";
            btn.classList.add("copied");
            setTimeout(() => {
                btn.innerText = "Copy";
                btn.classList.remove("copied");
            }, 2000);
        }
    });
}

// ------------------------------------------------------------------------------
// Search & Filter
// ------------------------------------------------------------------------------

function setupSearch() {
    const input = document.getElementById("search-input");
    if (!input) return;

    input.addEventListener("input", (e) => {
        let q = e.target.value.toLowerCase().trim();
        document.querySelectorAll(".sidebar-nav-item").forEach(item => {
            let title = item.querySelector(".sidebar-nav-link").innerText.toLowerCase();
            if (q === "" || title.includes(q)) {
                item.style.display = "block";
            } else {
                item.style.display = "none";
            }
        });

        // Hide empty groups
        document.querySelectorAll(".sidebar-group").forEach(group => {
            let visibleItems = Array.from(group.querySelectorAll(".sidebar-nav-item"))
                .filter(i => i.style.display !== "none");
            if (visibleItems.length === 0 && q !== "") {
                group.style.display = "none";
            } else {
                group.style.display = "block";
            }
        });
    });

    // Keyboard shortcut '/' focuses search
    document.addEventListener("keydown", (e) => {
        if (e.key === "/" && document.activeElement !== input) {
            e.preventDefault();
            input.focus();
        }
    });
}

// ------------------------------------------------------------------------------
// Sidebar Navigation Builder
// ------------------------------------------------------------------------------

function buildSidebar() {
    const navContainer = document.getElementById("sidebar-nav");
    if (!navContainer) return;

    let html = "";
    DOCS_NAV.forEach(group => {
        html += `
            <div class="sidebar-group">
                <div class="sidebar-group-title">${group.group}</div>
                <ul class="sidebar-nav-list">
        `;
        group.items.forEach(item => {
            html += `
                <li class="sidebar-nav-item">
                    <a href="#${item.id.replace(/\.md$/, "")}" class="sidebar-nav-link" data-id="${item.id}" onclick="loadChapter('${item.id}'); return false;">
                        <span class="chapter-num">${item.num}.</span>
                        <span>${item.title}</span>
                    </a>
                </li>
            `;
        });
        html += `
                </ul>
            </div>
        `;
    });

    navContainer.innerHTML = html;
}

// ------------------------------------------------------------------------------
// Initialization
// ------------------------------------------------------------------------------

document.addEventListener("DOMContentLoaded", () => {
    buildSidebar();
    setupSearch();

    // Mobile drawer toggle
    const toggleBtn = document.getElementById("mobile-toggle");
    const sidebar = document.getElementById("docs-sidebar");
    if (toggleBtn && sidebar) {
        toggleBtn.addEventListener("click", () => {
            sidebar.classList.toggle("open");
        });
    }

    // Determine initial chapter from hash (e.g. #04_variables_and_types)
    let initialDoc = "01_what_is_rad.md";
    let hash = window.location.hash.replace(/^#/, "");
    if (hash) {
        // If hash has subsection e.g. 04_variables_and_types#integers
        let parts = hash.split("#");
        let targetId = parts[0];
        let match = FLAT_DOCS.find(d => d.id === targetId || d.id === targetId + ".md");
        if (match) {
            initialDoc = match.id;
        }
    }

    loadChapter(initialDoc);
});
