import { Container, Nav, Navbar, NavDropdown } from 'react-bootstrap';
import stiLogo from '../assets/sti-icon.png';
import { Link } from 'react-router-dom';

const navItems = [
    { name: 'Home', path: '/' },
    { name: 'Contact', path: '/contact' },
    { name: 'About', path: '/about' },
    { name: 'Privacy Policy', path: '/privacy' },
];

const Header = () => {
    return (
        <Navbar collapseOnSelect expand="lg" className="bg-white">
            <Container>
                <Navbar.Brand href="/">
                    <img
                        src={stiLogo}
                        width="40"
                        height="40"
                        className="d-inline-block align-top"
                        alt="React Bootstrap logo"
                    />
                </Navbar.Brand>
                <Navbar.Toggle aria-controls="responsive-navbar-nav" />
                <Navbar.Collapse id="responsive-navbar-nav">
                    <Nav className='ms-auto text-uppercase gap-2'>
                        {navItems.map((item, index) => (
                            <Nav.Link key={index} href={item.path}>
                                {item.name}
                            </Nav.Link>
                        ))}
                    </Nav>
                </Navbar.Collapse>
            </Container>
        </Navbar>
    );
};

export default Header;