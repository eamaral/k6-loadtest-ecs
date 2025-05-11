import http from 'k6/http';
import { check, sleep } from 'k6';
import { htmlReport } from "https://raw.githubusercontent.com/benc-uk/k6-reporter/main/dist/bundle.js";

const RAMP_UP = __ENV.RPS_RAMP_UP || 1;
const RAMP_UP_DURATION = __ENV.DURATION_RAMP_UP || '3s';
const TARGET = __ENV.RPS_TARGET || 3;
const TARGET_DURATION = __ENV.DURATION_TARGET || '10s';
const RAMP_DOWN = __ENV.RPS_RAMP_DOWN || 1;
const RAMP_DOWN_DURATION = __ENV.DURATION_RAMP_DOWN || '3s';

export const options = {
    scenarios: {
        contacts: {
            executor: 'ramping-arrival-rate',
            startRate: RAMP_UP,
            timeUnit: '1s',
            preAllocatedVUs: 2000,
            stages: [
                { target: RAMP_UP, duration: RAMP_UP_DURATION },
                { target: TARGET, duration: '1s' },
                { target: TARGET, duration: TARGET_DURATION },
                { target: RAMP_DOWN, duration: RAMP_DOWN_DURATION },
            ],
        },
    },
    thresholds: {
        http_req_failed: ['rate < 0.01'],
        http_req_duration: [{ threshold: 'p(95) < 1000', abortOnFail: false, delayAbortEval: '10s' }],
    },
};

export default function () {
    let res = http.get('https://test-api.k6.io/public/crocodiles/');

    check(res, {
        'status is 200': (r) => r.status === 200,
    });

    sleep(1);
}

export function handleSummary(data) {
    const name = "_load_test";
    const fileName = "results/index" + name + ".html";
    return {
      [fileName]: htmlReport(data),
    };
}