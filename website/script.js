// website/script.js — Interactive features for Rad Landing Page

document.addEventListener('DOMContentLoaded', () => {
    // 1. Copy Install Command to Clipboard
    const copyBtn = document.getElementById('copy-btn');
    const copyText = document.getElementById('copy-text');
    const curlCmd = document.getElementById('curl-cmd');

    if (copyBtn && curlCmd) {
        copyBtn.addEventListener('click', async () => {
            const command = curlCmd.innerText.trim();
            try {
                await navigator.clipboard.writeText(command);
                copyBtn.classList.add('copied');
                copyText.innerText = 'Copied!';
                setTimeout(() => {
                    copyBtn.classList.remove('copied');
                    copyText.innerText = 'Copy';
                }, 2200);
            } catch (err) {
                // Fallback for older browsers
                const textarea = document.createElement('textarea');
                textarea.value = command;
                document.body.appendChild(textarea);
                textarea.select();
                document.execCommand('copy');
                document.body.removeChild(textarea);

                copyBtn.classList.add('copied');
                copyText.innerText = 'Copied!';
                setTimeout(() => {
                    copyBtn.classList.remove('copied');
                    copyText.innerText = 'Copy';
                }, 2200);
            }
        });
    }

    // 2. Interactive Code Tabs
    const tabButtons = document.querySelectorAll('.tab-btn');
    const codeContents = document.querySelectorAll('.code-content');

    tabButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            const tabId = btn.getAttribute('data-tab');

            // Deactivate all tabs and contents
            tabButtons.forEach(b => b.classList.remove('active'));
            codeContents.forEach(c => c.classList.remove('active'));

            // Activate targeted tab and content
            btn.classList.add('active');
            const targetContent = document.getElementById(tabId);
            if (targetContent) {
                targetContent.classList.add('active');
            }
        });
    });

    // 3. Smooth scrolling for internal anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const targetId = this.getAttribute('href').substring(1);
            const targetElement = document.getElementById(targetId);
            if (targetElement) {
                targetElement.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
});
