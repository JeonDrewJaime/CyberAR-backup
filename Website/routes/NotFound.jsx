import { useNavigate } from 'react-router-dom';
import Header from '../components/Header';

export const NotFound = () => {
    const navigate = useNavigate();

    const handleGoBack = (event) => {
        event.preventDefault();
        navigate(-1);
    };

    return (
        <>
            <Header />
            <div className="full-screen-bg">
                <div className="container">
                    <div className="row d-flex justify-content-center align-items-center">
                        <div className="col me-2">
                            <h2 className='my-4'>Page Not Found</h2>
                            <span>The page you are looking for does not exist.</span>
                            <div className="mt-4">
                                <a href="#" onClick={handleGoBack} className="btn btn-primary text-uppercase px-4">
                                    <i className="bi bi-arrow-left me-2"></i>
                                    Go Back
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </>
    );
};