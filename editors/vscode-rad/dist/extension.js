const vscode = require("vscode");
let client;

function activate(context) {
    const config = vscode.workspace.getConfiguration('rad');
    const radPath = config.get('lsp.path', 'rad');
    const radArgs = config.get('lsp.arguments', ['lsp']);

    try {
        const { LanguageClient } = require('vscode-languageclient/node');
        const serverOptions = {
            command: radPath,
            args: radArgs,
            options: { shell: false }
        };
        const clientOptions = {
            documentSelector: [{ scheme: 'file', language: 'rad' }],
            synchronize: {
                fileEvents: vscode.workspace.createFileSystemWatcher('**/*.rad')
            }
        };
        client = new LanguageClient('radLanguageServer', 'Rad Language Server', serverOptions, clientOptions);
        client.start();
    } catch (e) {
        console.log("Rad extension activated in syntax mode:", e);
    }

    context.subscriptions.push(
        vscode.commands.registerCommand('rad.restartLsp', async () => {
            if (client) {
                await client.stop();
                client.start();
                vscode.window.showInformationMessage('Rad Language Server restarted.');
            }
        })
    );
}

function deactivate() {
    if (!client) {
        return undefined;
    }
    return client.stop();
}

module.exports = {
    activate,
    deactivate
};
