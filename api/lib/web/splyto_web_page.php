<?php
declare(strict_types=1);

/**
 * Shared look for Splyto pages opened from a link: account emails and share links.
 * Colors, header band and accent bar match the account emails in helper_email.php.
 */
function splyto_web_page_styles(): string
{
    return <<<'CSS'
<meta name="color-scheme" content="light dark">
<meta name="theme-color" content="#F2F6F5" media="(prefers-color-scheme: light)">
<meta name="theme-color" content="#0F1A22" media="(prefers-color-scheme: dark)">
<style>
  :root {
    color-scheme: light dark;
    --page: #F2F6F5;
    --card: #FFFFFF;
    --stroke: #DFE8E5;
    --title: #0B1220;
    --body: #4A5763;
    --muted: #697182;
    --band: #15222E;
    --primary: #008576;
    --primary-hover: #006F62;
    --danger: #B83445;
    --danger-hover: #9C2A39;
    --field: #FFFFFF;
    --field-stroke: #C9D4D1;
    --focus: #00B8CF;
    --note-bg: #E8F4F3;
    --note-text: #33525A;
    --danger-bg: #FBECEE;
    --danger-text: #8E2433;
    --ok-bg: #E4F4EC;
    --ok-text: #1E6143;
  }
  @media (prefers-color-scheme: dark) {
    :root {
      --page: #0F1A22;
      --card: #17232E;
      --stroke: #26394A;
      --title: #FFFFFF;
      --body: #C3D0D6;
      --muted: #8FA3AD;
      --field: #0F1A22;
      --field-stroke: #35495A;
      --note-bg: #122A35;
      --note-text: #C3D6DD;
      --danger-bg: #331A20;
      --danger-text: #F2B8C0;
      --ok-bg: #143026;
      --ok-text: #A5E0C2;
    }
  }
  * { box-sizing: border-box; margin: 0; padding: 0; }
  [hidden] { display: none !important; }
  body {
    min-height: 100vh;
    min-height: 100dvh;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 24px 16px;
    background: var(--page);
    color: var(--body);
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
    font-size: 16px;
    line-height: 1.5;
    -webkit-text-size-adjust: 100%;
  }
  .card {
    width: 100%;
    max-width: 460px;
    overflow: hidden;
    background: var(--card);
    border: 1px solid var(--stroke);
    border-radius: 20px;
    box-shadow: 0 12px 40px rgba(11, 18, 32, 0.08);
  }
  .brand { display: flex; justify-content: center; padding: 26px 24px 22px; background: var(--band); }
  .brand img { display: block; width: 132px; height: auto; }
  .accent { display: flex; height: 3px; }
  .accent i { display: block; }
  .accent i:nth-child(1) { flex: 76; background: #008576; }
  .accent i:nth-child(2) { flex: 16; background: #00B8CF; }
  .accent i:nth-child(3) { flex: 8; background: #E51B88; }
  .content { padding: 28px 24px 26px; }
  h1 { margin-bottom: 8px; color: var(--title); font-size: 24px; line-height: 1.2; font-weight: 700; letter-spacing: -0.01em; overflow-wrap: anywhere; }
  p { margin-bottom: 14px; overflow-wrap: anywhere; }
  p:last-child { margin-bottom: 0; }
  .note, .status { margin: 18px 0; padding: 12px 14px; border-radius: 12px; font-size: 15px; overflow-wrap: anywhere; }
  .note { background: var(--danger-bg); color: var(--danger-text); }
  .status { background: var(--note-bg); color: var(--note-text); font-weight: 600; text-align: center; }
  .field { margin-bottom: 16px; }
  label { display: block; margin-bottom: 6px; color: var(--title); font-size: 14px; font-weight: 600; }
  input {
    display: block;
    width: 100%;
    min-height: 48px;
    padding: 12px 14px;
    background: var(--field);
    color: var(--title);
    border: 1px solid var(--field-stroke);
    border-radius: 12px;
    font: inherit;
    font-size: 16px;
  }
  input::placeholder { color: var(--muted); opacity: 1; }
  input:focus { outline: 2px solid var(--focus); outline-offset: 1px; border-color: transparent; }
  .help { margin-top: 6px; color: var(--muted); font-size: 13px; }
  .btn {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    min-height: 48px;
    padding: 12px 16px;
    border: 1px solid transparent;
    border-radius: 12px;
    background: var(--primary);
    color: #FFFFFF;
    font: inherit;
    font-weight: 600;
    text-align: center;
    text-decoration: none;
    cursor: pointer;
  }
  .btn:hover { background: var(--primary-hover); }
  .btn:focus-visible { outline: 2px solid var(--focus); outline-offset: 2px; }
  .btn:disabled { opacity: 0.5; cursor: not-allowed; }
  .btn:disabled:hover { background: var(--primary); }
  .btn-danger { background: var(--danger); }
  .btn-danger:hover { background: var(--danger-hover); }
  .btn-danger:disabled:hover { background: var(--danger); }
  .btn-secondary { margin-top: 10px; background: transparent; border-color: var(--field-stroke); color: var(--title); }
  .btn-secondary:hover { background: var(--note-bg); }
  .hint { margin-top: 14px; color: var(--muted); font-size: 13px; text-align: center; }
  .msg { display: none; margin-top: 16px; padding: 12px 14px; border-radius: 12px; font-size: 15px; overflow-wrap: anywhere; }
  .msg.success { display: block; background: var(--ok-bg); color: var(--ok-text); }
  .msg.error { display: block; background: var(--danger-bg); color: var(--danger-text); }
  .done .msg { margin-top: 0; }
</style>
CSS;
}

function splyto_web_page_header(): string
{
    return '<div class="brand"><img src="/email-logo-dark-v2.png" alt="Splyto" width="156" height="62"></div>'
        . '<div class="accent" aria-hidden="true"><i></i><i></i><i></i></div>';
}
