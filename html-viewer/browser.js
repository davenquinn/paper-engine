import './fonts.css';
import './browser.styl';
import './browser.js';
import html from './build/text.html'
import typeset from 'typeset'

//open links externally by default
// $(document).on('click', 'a[href^="http"]', function(event) {
//     event.preventDefault();
//     shell.openExternal(this.href);
// });

const buildElement = (el)=>{
  const div = document.createElement('div')
  console.log(html)
  div.className = "document"
  const pth = `file://${process.cwd()}/output/converted-includes/`
  const h = html.replace(/output\/converted-includes\//g, pth)
  div.innerHTML = typeset(h, {only: "p, ul, figcaption, caption"})

  el.appendChild(div)

}

buildElement(document.body)
