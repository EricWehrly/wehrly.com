const urlSegments = window.location.pathname.split('/');
const lastSegment = urlSegments[urlSegments.length - 1];

function buildNavItems() {
    fetch('menu.json')
        .then(response => response.json())
        .then(links => {            
            destroyAllNavItems();

            const navs = document.querySelectorAll('nav ul');

            navs.forEach((nav) => {
                links.forEach((link) => {
                    addMenuItem(link, nav);
                });
            });
        })
        .catch(error => {
            console.error('Error:', error);
        });
}

function addMenuItem(link, nav) {
    const li = document.createElement('li');
    li.classList.add('css-haue6f');

    const a = document.createElement('a');
    if (link.href === lastSegment) {
        a.className = 'css-4ju79q';
    } else {
        a.className = 'css-1w7ng4y';
    }
    a.setAttribute('href', link.href);
    a.textContent = link.text;

    if (link.rel) {
        a.setAttribute('rel', link.rel);
    }

    if (link.target) {
        a.setAttribute('target', link.target);
    }

    li.appendChild(a);
    nav.appendChild(li);
}

function destroyAllNavItems() {
    const navs = document.querySelectorAll('nav');

    navs.forEach((nav) => {
        const navItems = nav.querySelectorAll('li');

        navItems.forEach((item) => {
            item.remove();
        });
    });
}

(() => {
    buildNavItems();
})();
