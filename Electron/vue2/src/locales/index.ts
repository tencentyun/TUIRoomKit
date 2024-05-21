import Vue from 'vue';
import VueI18n from 'vue-i18n';
import { createI18n, useI18n } from 'vue-i18n-bridge';
import { getLanguage } from '../utils/utils';
import ZH from './zh-CN';
import EN from './en-US';

Vue.use(VueI18n, { bridge: true });

export default createI18n({
  legacy: false,
  locale: getLanguage() || 'zh-CN',
  messages: {
    'zh-CN': ZH,
    'en-US': EN,
  },
}, VueI18n);

export { useI18n };

