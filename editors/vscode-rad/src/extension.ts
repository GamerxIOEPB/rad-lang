import * as vscode from 'vscode';
import {
    LanguageClient,
    LanguageClientOptions,
    ServerOptions,
    Trace
} from 'vscode-languageclient/node';
import { execFile } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';

let client: LanguageClient | undefined;

function resolveRadPath(configuredPath: string): string {
    if (configuredPath && configuredPath !== 'rad') {
        if (fs.existsSync(configuredPath)) {
            return configuredPath;
        }
    }

    // 1. Check open workspace folders for local bin/rad
    const workspaceFolders = vscode.workspace.workspaceFolders;
    if (workspaceFolders) {
        for (const folder of workspaceFolders) {
            const candidate = path.join(folder.uri.fsPath, 'bin', 'rad');
            if (fs.existsSync(candidate)) {
                return candidate;
            }
        }
    }

    // 2. Check ~/.rad/bin/rad
    const home = process.env.HOME || process.env.USERPROFILE || '';
    if (home) {
        const homeRad = path.join(home, '.rad', 'bin', 'rad');
        if (fs.existsSync(homeRad)) {
            return homeRad;
        }
    }

    // 3. Fallback to configured path or "rad"
    return configuredPath || 'rad';
}

export function activate(context: vscode.ExtensionContext) {
    const config = vscode.workspace.getConfiguration('rad');
    const configuredPath = config.get<string>('lsp.path', 'rad');
    const radPath = resolveRadPath(configuredPath);
    const radArgs = config.get<string[]>('lsp.arguments', ['lsp']);
    const traceServer = config.get<string>('lsp.trace.server', 'off');

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
        },
        outputChannelName: 'Rad Language Server'
    };

    client = new LanguageClient(
        'radLanguageServer',
        'Rad Language Server',
        serverOptions,
        clientOptions
    );

    if (traceServer === 'verbose') {
        client.setTrace(Trace.Verbose);
    } else if (traceServer === 'messages') {
        client.setTrace(Trace.Messages);
    } else {
        client.setTrace(Trace.Off);
    }

    // Register extension commands
    context.subscriptions.push(
        vscode.commands.registerCommand('rad.restartLsp', async () => {
            if (client) {
                try {
                    await client.stop();
                } catch {
                    // Ignore stop error
                }
                try {
                    await client.start();
                    vscode.window.showInformationMessage('Rad Language Server restarted.');
                } catch (err: any) {
                    vscode.window.showErrorMessage(`Failed to restart Rad Language Server: ${err.message || err}`);
                }
            }
        }),

        vscode.commands.registerCommand('rad.showVersion', () => {
            execFile(radPath, ['--version'], (error, stdout, stderr) => {
                if (error) {
                    vscode.window.showErrorMessage(`Failed to execute '${radPath} --version': ${stderr || error.message}`);
                    return;
                }
                vscode.window.showInformationMessage(`Rad Toolchain: ${stdout.trim()} (${radPath})`);
            });
        }),

        vscode.commands.registerCommand('rad.formatFile', async () => {
            await vscode.commands.executeCommand('editor.action.formatDocument');
        })
    );

    client.start().catch((err: any) => {
        vscode.window.showErrorMessage(`Failed to start Rad Language Server using '${radPath}': ${err.message || err}`);
    });
}

export function deactivate(): Thenable<void> | undefined {
    if (!client) {
        return undefined;
    }
    return client.stop();
}
