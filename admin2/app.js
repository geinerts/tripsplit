// Splyto admin panel entry. Every module import carries the same ?v= as this
// file in index.html (Cloudflare caches static files); bump them together.
import './js/views/dashboard.js?v=23';
import './js/views/users.js?v=23';
import './js/views/features.js?v=23';
import './js/views/premium.js?v=23';
import './js/views/operations.js?v=23';
import './js/views/logs.js?v=23';
import './js/views/admin.js?v=23';
import { boot } from './js/auth.js?v=23';

boot();
