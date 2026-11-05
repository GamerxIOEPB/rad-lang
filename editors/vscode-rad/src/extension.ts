import * as vscode from 'vscode';
import {
    LanguageClient,
    LanguageClientOptions,
    ServerOptions
} from 'vscode-languageclient/node';

let client: LanguageClient | undefined;

export function activate(context: vscode.ExtensionContext) {
    const config = vscode.workspace.getConfiguration('rad');
    const radPath = config.get<string>('lsp.path', 'rad');
    const radArgs = config.get<string[]>('lsp.arguments', ['lsp']);

    const serverOptions: ServerOptions = {
        command: radPath,
        args: radArgs,
        options: {
            shell: false
        }
    };

    const clientOptions: LanguageClientOptions = {
        documentSelector: [{ scheme: 'file', language: 'rad' }],
        synchronize: {
            fileEvents: vscode.workspace.createFileSystemWatcher('**/*.rad')
        }
    };

    client = new LanguageClient(
        'radLanguageServer',
        'Rad Language Server',
        serverOptions,
        clientOptions
    );

    context.subscriptions.push(
        vscode.commands.registerCommand('rad.restartLsp', async () => {
            if (client) {
                await client.stop();
                client.start();
                vscode.window.showInformationMessage('Rad Language Server restarted.');
            }
        })
    );

    client.start();
}

export function deactivate(): Thenable<void> | undefined {
    if (!client) {
        return undefined;
    }
    return client.stop();
}
