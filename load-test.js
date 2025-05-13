import http from 'k6/http';
import { check, sleep } from 'k6';
import { htmlReport } from "https://raw.githubusercontent.com/benc-uk/k6-reporter/main/dist/bundle.js";

// Parâmetros configuráveis via pipeline
const RAMP_UP = __ENV.RPS_RAMP_UP || 1;
const RAMP_UP_DURATION = __ENV.DURATION_RAMP_UP || '3s';
const TARGET = __ENV.RPS_TARGET || 3;
const TARGET_DURATION = __ENV.DURATION_TARGET || '10s';
const RAMP_DOWN = __ENV.RPS_RAMP_DOWN || 1;
const RAMP_DOWN_DURATION = __ENV.DURATION_RAMP_DOWN || '3s';

// Configuração do cenário de carga
export const options = {
    scenarios: {
        test_scenario: {
            executor: 'ramping-arrival-rate',
            startRate: RAMP_UP,
            timeUnit: '1s',
            preAllocatedVUs: 100,
            maxVUs: 1000,
            stages: [
                { target: RAMP_UP, duration: RAMP_UP_DURATION },
                { target: TARGET, duration: '1s' },
                { target: TARGET, duration: TARGET_DURATION },
                { target: RAMP_DOWN, duration: RAMP_DOWN_DURATION },
            ],
        },
    },
    thresholds: {
        http_req_failed: ['rate<0.01'],
        http_req_duration: ['p(95)<1000'],
    },
};

// Função principal da execução
export default function () {
    const res = http.get('https://test-api.k6.io/public/crocodiles/');
    check(res, {
        'status is 200': (r) => r.status === 200,
    });
    sleep(1);
}

// Geração do relatório HTML
export function handleSummary(data) {
    const fileName = "/home/k6/results/index_load_test.html";
    return {
        [fileName]: htmlReport(data),
    };
}

