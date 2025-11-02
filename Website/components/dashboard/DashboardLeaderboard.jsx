import { Container, Pagination, Table } from "react-bootstrap";
import Loading from "../Loading";
import { useState } from "react";

const DashboardLeaderboard = ({ leaderboardData }) => {
  const [currentPage, setCurrentPage] = useState(1);
  const [loading, setLoading] = useState(false);
  const itemsPerPage = 5;

  const indexOfLastItem = currentPage * itemsPerPage;
  const indexOfFirstItem = indexOfLastItem - itemsPerPage;
  const currentData = leaderboardData.slice(indexOfFirstItem, indexOfLastItem);
  const totalPages = Math.ceil(leaderboardData.length / itemsPerPage);

  const handlePageChange = (direction) => {
    if (direction === "next" && currentPage < totalPages) {
      setCurrentPage((prev) => prev + 1);
    } else if (direction === "prev" && currentPage > 1) {
      setCurrentPage((prev) => prev - 1);
    }
  };

  return (
    <div>
      <Container className='my-4'>
        <span className="fs-5 fw-bold mb-4">Leaderboard</span>
        <div>
          <Table bordered hover>
            <thead>
              <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Total Score</th>
              </tr>
            </thead>
            <tbody>
              {currentData.map((student, index) => (
                <tr key={index}>
                  <td>{student.name}</td>
                  <td>{student.email}</td>
                  <td>{student.totalScore}</td>
                </tr>
              ))}
            </tbody>
          </Table>

          <Pagination className="justify-content-center mt-4">
            <Pagination.Prev
              disabled={currentPage === 1}
              onClick={() => handlePageChange("prev")}
            />
            <Pagination.Item active>{currentPage}</Pagination.Item>
            <Pagination.Next
              disabled={currentPage === totalPages}
              onClick={() => handlePageChange("next")}
            />
          </Pagination>
        </div>
      </Container>
    </div>
  )
}

export default DashboardLeaderboard
