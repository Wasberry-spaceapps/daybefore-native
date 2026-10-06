const { spawn } = require('child_process');

function runWrangler(args, inputs = []) {
    return new Promise((resolve, reject) => {
        const proc = spawn('node', ['./node_modules/wrangler/bin/wrangler.js', ...args], {
            env: { ...process.env, CI: '1', WRANGLER_SEND_METRICS: 'false' },
            shell: true
        });

        let output = '';

        proc.stdout.on('data', (data) => {
            console.log(data.toString());
            output += data.toString();
            // Automatically answer "no" to prompts
            if (data.toString().toLowerCase().includes('would you like')) {
                proc.stdin.write('no\n');
            }
        });

        proc.stderr.on('data', (data) => {
            console.error(data.toString());
        });

        // Send any specific inputs
        inputs.forEach(input => proc.stdin.write(input + '\n'));

        proc.on('close', (code) => {
            if (code === 0) resolve(output);
            else reject(new Error(`Exited with code ${code}`));
        });
    });
}

async function main() {
    try {
        console.log("Creating DB...");
        const d1Out = await runWrangler(['d1', 'create', 'daybefore_db']);
        
        // Extract DB ID
        const match = d1Out.match(/database_id = "([^"]+)"/);
        if (match) {
            const dbId = match[1];
            console.log("DB ID:", dbId);
            
            // Update wrangler.toml
            const fs = require('fs');
            let toml = fs.readFileSync('wrangler.toml', 'utf8');
            toml = toml.replace(/database_id = ".*"/, `database_id = "${dbId}"`);
            fs.writeFileSync('wrangler.toml', toml);
            
            console.log("Executing schema...");
            await runWrangler(['d1', 'execute', 'daybefore_db', '--remote', '--file=./schema.sql']);
            
            console.log("Setting API KEY...");
            await runWrangler(['secret', 'put', 'PADDLE_API_KEY'], ['pdl_sdbx_apikey_01m3hky3a9mh97r9tbexh0zkj1_Sf4FyZ2sdz1KEmrB40f2Aw_A8S']);
            
            console.log("Setting WEBHOOK SECRET...");
            await runWrangler(['secret', 'put', 'PADDLE_WEBHOOK_SECRET'], ['pdl_ntfset_01m3hr9n916kybg8jdy01xjhgv_8zebxI/kyoe3Ybo4MLmeR3/yPen49awK']);
            
            console.log("Setting JWT SECRET...");
            await runWrangler(['secret', 'put', 'JWT_SECRET'], ['super_secret_for_local_dev']);
            
            console.log("Deploying...");
            await runWrangler(['deploy']);
            console.log("DONE!");
        } else {
            console.error("Could not find database_id in output");
        }
    } catch (e) {
        console.error(e);
    }
}

main();
